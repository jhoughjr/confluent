//
//  FluentGenerator.swift
//  ConFluent
//
//  Created by Jimmy Hough Jr on 3/21/23.
//

import Foundation
import Combine
class FluentGenerator:ObservableObject {
    
    enum FilePathType:String {
        case model
        case migration
        case controller
        case project
    }
    
    class Field:ObservableObject {
        
        enum FieldType:String, CaseIterable {
            case string
            case bool
            case datetime
            case time
            case date
            case float
            case double
            case data
            case uuid
            case dictionary
            case array
            case enumeration
            case custom
            
            func migration() -> String {
                switch self {
                    
                case .string:
                    return ".string"
                case .bool:
                    return ".bool"
                case .datetime:
                    return ".datetime"
                case .time:
                    return ".time"
                case .date:
                    return ".date"
                case .float:
                    return ".float"
                case .double:
                    return ".double"
                case .data:
                    return ".data"
                case .uuid:
                    return ".uuid"
                case .dictionary:
                    return ".dictionary"
                case .array:
                    return ".array"
                case .enumeration:
                    return ".enum"
                case .custom:
                    return "not implemented"
                }
            }
            func swiftType() -> String {
                switch self {
                    
                case .string:
                    return "String"
                case .bool:
                    return "Bool"
                case .datetime:
                    return "Date"
                case .time:
                    return "Date"
                case .date:
                    return "Date"
                case .float:
                    return "Float"
                case .double:
                    return "Double"
                case .data:
                    return "Data"
                case .uuid:
                    return "UUID"
                case .dictionary:
                    return "Dictionary<T>"
                case .array:
                    return "[T]"
                case .enumeration:
                    return "not implemented"
                case .custom:
                    return ""
                }
            }
        }
        
        @Published var name = "" // swift name
        @Published var key = "" // db name. same as name unless speccified
        @Published var isOptional = false
        @Published var type:FieldType = .string   // should get this from string enum
        @Published var id = UUID()
        
        func declaration() -> String {
           
            return """
            @\(isOptional ? "OptionalField" :"Field")(key:"\(key.isEmpty ? name : key)")
            \tvar \(name):\(type.swiftType())\(isOptional ? "?" : "")
            """
        }
        
        func migration() -> String {
            """
            .field("\(key.isEmpty ? name : key)","\(type.migration())",\(isOptional ? "" : ".required"))
            """
        }
        
    }

    // input
    @Published var name = "" // Class name
    @Published var fields = [FluentGenerator.Field]()
    
    @Published var timestamps = true // .createdAt, .updatedAt
    
    // output paths
    @Published var projectPath = ""
    @Published var modelPath = ""
    @Published var migrationPath = ""
    @Published var controllerPath = ""
    
    // output
    @Published var generatedModel = ""
    @Published var generatedMigration = ""
    @Published var generatedController = ""
    
    func generateModel() {
        generatedModel +=
    """
    import Fluent

    final class \(name): Model {
    \tstatic let schema = "\(name.lowercased())s"\n
    \t@ID(.id)
    \tvar id:UUID?\n\n
    """
        for field in fields {
            generatedModel += "\t" + field.declaration() + "\n\n"
        }
        if timestamps {
            generatedModel +=
            """
            \t@Timestamp(key: "created_at", on: .create)
            \tvar createdAt: Date?

            \t@Timestamp(key: "updated_at", on: .update)
            \tvar updatedAt: Date?\n\n
            """
        }
        generatedModel +=
        """
        \tinit(id: UUID?,
        """
        for (i,field) in fields.enumerated() {
            if i != fields.count - 1 {
                generatedModel += "\(field.name): \(field.type.swiftType())\(field.isOptional ? "?" : ""), "
            }
            else {
                generatedModel += "\(field.name): \(field.type.swiftType())\(field.isOptional ? "?" : "")"
            }
        }
        
        generatedModel += ") {\n"
        for field in fields {
            generatedModel += "\t\tself.\(field.name) = \(field.name)\n"
        }
        generatedModel += "\t}\n}\n"
    }
    
    func generateMigration() {
        generatedMigration +=
        """
        import Fluent
        
        struct Create\(name)Mirgration: AsyncMigration {
            func prepare(on database: Database) async throws {
            \tdatabase.schema("\(name.lowercased())s")
            \t.id()\n
        """
        for field in fields {
            generatedMigration +=  "\t\t" + field.migration() + "\n"
        }
        
        if timestamps {
            generatedMigration +=
            """
            \t\t.field("created_at", .datetime, .required)
            \t\t.field("updated_at", .datetime, .required)\n
            """
        }
        
        generatedMigration +=
        """
        \t\t.create()
        \t}

        \tfunc revert(on database: Database) async throws {
        \t// Undo the change made in `prepare`, if possible.
        \t\tdatabase.schema("\(name.lowercased())s").delete()
        \t}
        }
        """
    }
    
    func generateController() {
        generatedController +=
        """
        import Vapor
        import Fluent

        struct \(name)Controller:RouteCollection {
        
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
        
            func boot(routes: RoutesBuilder) throws {
                routes.get("all") { req in
                    let all = \(name).query(on:req.db).all()
                    let allCoded = try encoder.encode([\(name)],
                                                      with:all)
                    return Response(status:.ok, body:allCoded)
                }
                
                routes.get(":id") { req in
                    guard let id = req.parameters.get("id") else {
                        return Response(status:.notFound)
                    }
                    // think i can find by id isntead here
                    if let one = \(name).find(id, on:req.db) {
                        
                        return Response(status:.ok)
                    }
                    else {
                        return Response(status:.notFound)
                    }
                }
                
                routes.post("") {req in
                    return Response(status:.ok)
                }
            }
        }
        """
    }
    
    // action
    func generate() {
        generateModel()
        generateMigration()
        generateController()
    }
    
    public func exportModel() {
        guard !modelPath.isEmpty else { return }
        guard let url = URL(string: modelPath)?.appending(path: "\(name)")
            .appendingPathExtension("swift") else {
            return
        }
        do {
            try generatedModel.data(using: .utf8)?.write(to: url)
        }
        catch {
            print(error)
        }
    }
    
    public func exportMigration() {
        guard !migrationPath.isEmpty else { return }
        guard let url = URL(string: migrationPath)?.appending(path: "Create\(name)Migration")
            .appendingPathExtension("swift") else {
            return
        }
        do {
            try generatedMigration.data(using: .utf8)?.write(to: url)
        }
        catch {
            print(error)
        }
    }
    
    public func exportController() {
        guard !controllerPath.isEmpty else { return }
        guard let url = URL(string: controllerPath)?.appending(path: "\(name)Controller")
            .appendingPathExtension("swift") else {
            return
        }
        do {
            try generatedMigration.data(using: .utf8)?.write(to: url)
        }
        catch {
            print(error)
        }
    }
}
