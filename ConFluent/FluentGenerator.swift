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
        
        @Published var name = "" // swift name
        @Published var key = "" // db name. same as name unless speccified
        @Published var isOptional = false
        @Published var type = "String"    // should get this from string enum
        @Published var dbType = ".string" // need to enumerate this
        @Published var id = UUID()
        
        func declaration() -> String {
           
            return """
            @\(isOptional ? "OptionalField" :"Field")(key:"\(key.isEmpty ? name : key)")
            \tvar \(name):\(type)\(isOptional ? "?" : "")
            """
        }
        
        func migration() -> String {
            """
            .field("\(key.isEmpty ? name : key)","\(dbType)",\(isOptional ? "" : ".required"))
            """
        }
        
        func migrationTypeFor(type:String) -> String {
            if type == "String" {
               return ".string"
            }
            return ""
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
    
    // action
    func generate() {
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
                generatedModel += "\(field.name): \(field.type)\(field.isOptional ? "?" : ""), "
            }
            else {
                generatedModel += "\(field.name): \(field.type)\(field.isOptional ? "?" : "")"
            }
        }
        
        generatedModel += ") {\n"
        for field in fields {
            generatedModel += "\t\tself.\(field.name) = \(field.name)\n"
        }
        generatedModel += "\t}\n}\n"
        
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

}
