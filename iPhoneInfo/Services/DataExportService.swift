//
//  DataExportService.swift
//  iPhoneInfo
//
//  Data export service (CSV/JSON/PDF)
//

import Foundation
import PDFKit
import UIKit

// MARK: - Export Format
enum ExportFormat: String, CaseIterable {
    case csv = "csv"
    case json = "json"
    case pdf = "pdf"

    var displayName: String {
        switch self {
        case .csv: return "CSV"
        case .json: return "JSON"
        case .pdf: return "PDF"
        }
    }

    var fileExtension: String {
        switch self {
        case .csv: return "csv"
        case .json: return "json"
        case .pdf: return "pdf"
        }
    }

    var mimeType: String {
        switch self {
        case .csv: return "text/csv"
        case .json: return "application/json"
        case .pdf: return "application/pdf"
        }
    }
}

// MARK: - Export Error
enum ExportError: LocalizedError {
    case noData
    case exportFailed
    case fileAccessError

    var errorDescription: String? {
        switch self {
        case .noData:
            return "没有可导出的数据"
        case .exportFailed:
            return "导出失败"
        case .fileAccessError:
            return "文件访问错误"
        }
    }
}

// MARK: - Data Export Service
class DataExportService {
    static let shared = DataExportService()

    private let historyManager = BenchmarkHistoryManager.shared

    // Export configuration
    struct ExportConfig {
        let format: ExportFormat
        let includeDetails: Bool
        let dateRange: DateInterval?
        let limit: Int?

        static let `default` = ExportConfig(
            format: .csv,
            includeDetails: true,
            dateRange: nil,
            limit: nil
        )
    }

    // MARK: - Public Methods

    /// Export benchmark history
    func exportHistory(config: ExportConfig = .default) async throws -> URL {
        // Fetch data
        let results = historyManager.fetchAll()

        guard !results.isEmpty else {
            throw ExportError.noData
        }

        // Apply filters
        let filteredResults = filterResults(results, config: config)

        // Generate content
        let content: Data

        switch config.format {
        case .csv:
            content = try generateCSV(filteredResults, includeDetails: config.includeDetails)

        case .json:
            content = try generateJSON(filteredResults, includeDetails: config.includeDetails)

        case .pdf:
            content = try generatePDF(filteredResults, includeDetails: config.includeDetails)
        }

        // Save to file
        let fileName = generateFileName(format: config.format)
        let url = try saveToDocuments(content, fileName: fileName)

        return url
    }

    /// Export single benchmark result
    func exportResult(_ result: ComprehensiveBenchmarkResult, format: ExportFormat) async throws -> URL {
        let content: Data

        switch format {
        case .csv:
            content = try generateCSV([result], includeDetails: true)

        case .json:
            content = try generateJSON([result], includeDetails: true)

        case .pdf:
            content = try generatePDF([result], includeDetails: true)
        }

        let fileName = "iPhoneInfo_\(formatFileNameDate(result.date)).\(format.fileExtension)"
        let url = try saveToDocuments(content, fileName: fileName)

        return url
    }

    /// Share result (generates shareable content)
    func generateShareContent(for result: ComprehensiveBenchmarkResult, format: ExportFormat) async throws -> Any {
        switch format {
        case .csv:
            let data = try generateCSV([result], includeDetails: true)
            return data

        case .json:
            let data = try generateJSON([result], includeDetails: true)
            return data

        case .pdf:
            let data = try generatePDF([result], includeDetails: true)
            return data
        }
    }

    // MARK: - Private Methods

    private func filterResults(_ results: [BenchmarkResultEntity], config: ExportConfig) -> [BenchmarkResultEntity] {
        var filtered = results

        // Apply date range filter
        if let range = config.dateRange {
            filtered = filtered.filter { result in
                guard let date = result.date else { return false }
                return range.contains(date)
            }
        }

        // Apply limit
        if let limit = config.limit {
            filtered = Array(filtered.prefix(limit))
        }

        return filtered
    }

    // MARK: - CSV Generation
    private func generateCSV(_ results: [BenchmarkResultEntity], includeDetails: Bool) throws -> Data {
        var csv = ""

        // Header
        csv += "测试日期,设备型号,CPU得分,GPU得分,内存得分,存储得分,总分,等级,测试类型,测试耗时"
        if includeDetails {
            csv += ",详细信息\n"
        } else {
            csv += "\n"
        }

        // Rows
        for result in results {
            let date = result.date?.formatted(date: .abbreviated) ?? "未知"
            let model = result.deviceModel ?? "未知"
            let details = includeDetails ? (result.details?.addingBackslashEscapes ?? "") : ""

            csv += "\(date),\(model),\(result.cpuScore),\(result.gpuScore),\(result.memoryScore),\(result.storageScore),\(result.totalScore),\(result.grade ?? ""),\(result.testType ?? ""),\(String(format: "%.1f", result.testDuration))"

            if includeDetails {
                csv += ",\"\(details)\"\n"
            } else {
                csv += "\n"
            }
        }

        guard let data = csv.data(using: .utf8) else {
            throw ExportError.exportFailed
        }

        return data
    }

    // MARK: - JSON Generation
    private func generateJSON(_ results: [BenchmarkResultEntity], includeDetails: Bool) throws -> Data {
        var exportData: [[String: Any]] = []

        for result in results {
            var row: [String: Any] = [
                "date": result.date?.ISO8601String() ?? "",
                "deviceModel": result.deviceModel ?? "",
                "cpuScore": result.cpuScore,
                "gpuScore": result.gpuScore,
                "memoryScore": result.memoryScore,
                "storageScore": result.storageScore,
                "totalScore": result.totalScore,
                "grade": result.grade ?? "",
                "testType": result.testType ?? "",
                "testDuration": result.testDuration
            ]

            if includeDetails, let details = result.details {
                row["details"] = details
            }

            exportData.append(row)
        }

        let json: [String: Any] = [
            "version": 1,
            "exportDate": Date().ISO8601String(),
            "count": exportData.count,
            "results": exportData
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            throw ExportError.exportFailed
        }

        return data
    }

    // MARK: - PDF Generation
    private func generatePDF(_ results: [BenchmarkResultEntity], includeDetails: Bool) throws -> Data {
        let pdfDocument = PDFDocument()
        var currentPage = PDFPage()
        var currentY: CGFloat = 0
        let margin: CGFloat = 50
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let contentWidth = pageWidth - (margin * 2)

        // Title
        currentY = drawText(on: &currentPage, at: CGPoint(x: margin, y: currentY),
                          text: "iPhone 性能测试报告",
                          font: .boldSystemFont(ofSize: 24),
                          color: .black,
                          maxWidth: contentWidth)
        currentY += 40

        // Export info
        currentY = drawText(on: &currentPage, at: CGPoint(x: margin, y: currentY),
                          text: "导出日期: \(Date().formatted(date: .long))",
                          font: .systemFont(ofSize: 12),
                          color: .gray,
                          maxWidth: contentWidth)
        currentY += 30

        // Summary
        currentY = drawText(on: &currentPage, at: CGPoint(x: margin, y: currentY),
                          text: "测试记录数: \(results.count)",
                          font: .systemFont(ofSize: 14),
                          color: .black,
                          maxWidth: contentWidth)
        currentY += 30

        // Add page if needed
        if currentY > pageHeight - margin {
            pdfDocument.add(currentPage)
            currentPage = PDFPage()
            currentY = margin
        }

        // Results table
        for (index, result) in results.enumerated() {
            // Check if we need a new page
            let rowHeight: CGFloat = includeDetails ? 150 : 100
            if currentY + rowHeight > pageHeight - margin {
                pdfDocument.add(currentPage)
                currentPage = PDFPage()
                currentY = margin
            }

            // Result card
            currentY = drawResultCard(on: &currentPage, at: CGPoint(x: margin, y: currentY),
                                       result: result,
                                       includeDetails: includeDetails,
                                       maxWidth: contentWidth)
            currentY += 20
        }

        pdfDocument.add(currentPage)

        guard let data = pdfDocument.data else {
            throw ExportError.exportFailed
        }

        return data
    }

    // MARK: - PDF Drawing Helpers
    private func drawText(on page: inout PDFPage, at point: CGPoint, text: String, font: UIFont, color: UIColor, maxWidth: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let bounds = CGRect(x: point.x, y: point.y, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        attributedString.draw(in: bounds)

        let size = attributedString.size()
        return size.height + 8
    }

    private func drawResultCard(on page: inout PDFPage, at point: CGPoint, result: BenchmarkResultEntity, includeDetails: Bool, maxWidth: CGFloat) -> CGFloat {
        var currentY = point.y
        let lineHeight: CGFloat = 20

        // Card background
        let cardHeight: CGFloat = includeDetails ? 120 : 80

        // Title
        let title = "测试 #\(result.id?.uuidString.prefix(8) ?? "?")"
        currentY = drawText(on: &page, at: CGPoint(x: point.x + 10, y: currentY),
                          text: title,
                          font: .boldSystemFont(ofSize: 14),
                          color: .black,
                          maxWidth: maxWidth)
        currentY += lineHeight

        // Date and device
        let info = "\(result.date?.formatted(date: .abbreviated) ?? "") | \(result.deviceModel ?? "")"
        currentY = drawText(on: &page, at: CGPoint(x: point.x + 10, y: currentY),
                          text: info,
                          font: .systemFont(ofSize: 12),
                          color: .gray,
                          maxWidth: maxWidth)
        currentY += lineHeight

        // Scores
        let scores = "CPU: \(result.cpuScore) | GPU: \(result.gpuScore) | 内存: \(result.memoryScore) | 总分: \(result.totalScore)"
        currentY = drawText(on: &page, at: CGPoint(x: point.x + 10, y: currentY),
                          text: scores,
                          font: .systemFont(ofSize: 12),
                          color: .black,
                          maxWidth: maxWidth)
        currentY += lineHeight

        if includeDetails, let details = result.details {
            currentY = drawText(on: &page, at: CGPoint(x: point.x + 10, y: currentY),
                              text: String(details.prefix(100)),
                              font: .systemFont(ofSize: 10),
                              color: .gray,
                              maxWidth: maxWidth)
            currentY += lineHeight
        }

        // Grade badge
        let grade = result.grade ?? "-"
        let gradeColor = gradeColor(grade)

        let gradeRect = CGRect(x: point.x + maxWidth - 40, y: point.y, width: 35, height: 20)
        currentY = drawText(on: &page, at: CGPoint(x: gradeRect.midX, y: gradeRect.midY - 10),
                          text: grade,
                          font: .boldSystemFont(ofSize: 12),
                          color: gradeColor,
                          maxWidth: 35)

        // Border
        let borderRect = CGRect(x: point.x, y: point.y - 20, width: maxWidth, height: cardHeight)
        let path = UIBezierPath(rect: borderRect)
        path.stroke()
        path.lineWidth = 1
        UIColor.gray.setStroke()
        path.stroke()

        return cardHeight + 10
    }

    // MARK: - File Operations
    private func saveToDocuments(_ data: Data, fileName: String) throws -> URL {
        let fileManager = FileManager.default

        // Get documents directory
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ExportError.fileAccessError
        }

        let fileURL = documentsURL.appendingPathComponent(fileName)

        // Remove existing file if exists
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL.path)
        }

        // Write new file
        try data.write(to: fileURL)

        return fileURL
    }

    // MARK: - Helper Methods
    private func generateFileName(format: ExportFormat) -> String {
        let dateString = formatFileNameDate(Date())
        return "iPhoneInfo_Export_\(dateString).\(format.fileExtension)"
    }

    private func formatFileNameDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: date)
    }

    private func formatFileNameDate(_ result: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: result)
    }

    private func gradeColor(_ grade: String) -> UIColor {
        switch grade {
        case "S": return .systemPurple
        case "A": return .systemGreen
        case "B": return .systemBlue
        case "C": return .systemOrange
        case "D": return .systemRed
        default: return .gray
        }
    }
}

// MARK: - String Extension for Escaping
extension String {
    func addingBackslashEscapes() -> String {
        return self
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
    }
}

// MARK: - Extension to add page to PDF
extension PDFDocument {
    func add(_ page: PDFPage) {
        insert(page, at: pageCount)
    }
}

// MARK: - PDFPage Helper
extension PDFPage {
    convenience init() {
        self.init(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
    }
}
