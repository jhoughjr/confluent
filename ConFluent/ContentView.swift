//
//  ContentView.swift
//  ConFluent
//
//  Created by Jimmy Hough Jr on 3/20/23.
//

import SwiftUI
import CodeEditor


struct ContentView: View {
    var body: some View {
        NewModelView()
    }
}

struct NewModelView: View {
  
    @AppStorage("lastModelPath")
    var lastModelPath = ""
    
    @AppStorage("lastMigrationPath")
    var lastMigrationPath = ""
    
    @AppStorage("lastcontrollerPath")
    var lastControllerPath = ""
    
    // model
    @ObservedObject var generator = FluentGenerator()
    
    // views
    private var fieldsView: some View {
        VStack(alignment:.leading) {
            ForEach(generator.fields,
                    id:\.id) { field in
                FieldView(field: field)
            }
        }
    }

    private var generateButton: some View {
        Button {
            generator.generatedModel = ""
            generator.generatedMigration = ""
            generator.generatedController = ""
            generator.generate()
        } label: {
            Text("Generate Files")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var addFieldButton: some View {
        Button(action: {
            generator.fields.append(FluentGenerator.Field())
        }, label: {
            HStack {
                Image(systemName: "plus")
                Text("Add Field")
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    private var browseModelPathButton: some View {
        Button {
            open(type: FluentGenerator.FilePathType.model)
        } label: {
            Text("Browse")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var exportModelButton: some View {
        Button {
            //write to model path
            generator.exportModel()
        } label: {
            Text("Export")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var browseMigrationPathButton: some View {
        Button {
            open(type: FluentGenerator.FilePathType.migration)
        } label: {
            Text("Browse")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var exportMigrationButton: some View {
        Button {
            generator.exportMigration()
        } label: {
            Text("Export")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var browseControllerPathButton: some View {
        Button {
            open(type: FluentGenerator.FilePathType.controller)
        } label: {
            Text("Browse")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var exportControllerButton: some View {
        Button {
            generator.exportController()
        } label: {
            Text("Export")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var modelExportView: some View {
        VStack(alignment: .leading) {
            Text("Model")
                .font(.title)
            Divider()
            HStack {
                browseModelPathButton
                HStack {
                    Text("\(generator.modelPath)")
                        .font(.title2)
                        .truncationMode(.middle)
                        .lineLimit(1)
                    Text("\(generator.name).swft")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                exportModelButton
            }
            CodeEditor(source: $generator.generatedModel,
                       language: .swift)
        }
       
    }
    
    private var migrationExportView: some View {
        VStack(alignment:.leading) {
            Text("Migration")
                .font(.title)
            Divider()
            HStack {
                browseMigrationPathButton
                HStack {
                    Text("\(generator.migrationPath)")
                        .font(.title2)
                        .truncationMode(.middle)
                        .lineLimit(1)
                    Text("Create\(generator.name)Migration.swit")
                        .foregroundColor(.gray)
                }
                exportMigrationButton
            }
            CodeEditor(source: $generator.generatedMigration,
                       language: .swift)
        }
    }
    
    private var controllerExportView: some View {
        VStack(alignment:.leading) {
            Text("Controller")
                .font(.title)
            Divider()
            HStack {
                browseControllerPathButton
                HStack {
                    Text("\(generator.controllerPath)")
                        .font(.title2)
                        .truncationMode(.middle)
                        .lineLimit(1)
                    Text("\(generator.name)Controller.swift")
                        .foregroundColor(.gray)
                }
                exportControllerButton
            }
            CodeEditor(source: $generator.generatedController,
                       language: .swift)
        }
    }
    
    private var exportView: some View {
        VStack(alignment:.leading) {
            modelExportView
            migrationExportView
            controllerExportView
        }
        .padding()
    }
    
    private var designView: some View {
        VStack(alignment:.leading) {
            Text("Design")
                .font(.title)
            Divider()
            Text("Entity Name")
                .font(.title2)

            TextField("Name", text: $generator.name)
            Text("Fields")
                .font(.title2)
            Toggle("Include Timestamps",
                   isOn: $generator.timestamps)
            List {
                fieldsView
                HStack {
                    Spacer()
                    addFieldButton
                }
            }
            HStack {
                Spacer()
                generateButton
                    .padding([.trailing], 24)
            }
            
        }
        .padding()
    }
    
    var body: some View {
        HStack {
           designView
           exportView
        }
    }
    
    public func open(type:FluentGenerator.FilePathType) {
        
        let panel = NSOpenPanel()
               panel.allowsMultipleSelection = false
               panel.canChooseDirectories = true
        if panel.runModal() == .OK {
            switch type {
                
            case .model:
                generator.modelPath = panel.url?.absoluteString ?? ""
                lastModelPath = generator.modelPath
            case .migration:
                generator.migrationPath = panel.url?.absoluteString ?? ""
                lastMigrationPath = generator.migrationPath
            case .controller:
                generator.controllerPath = panel.url?.absoluteString ?? ""
                lastControllerPath = generator.controllerPath
            case .project:
                generator.projectPath = panel.url?.absoluteString ?? ""
            
            }
        }
        else {
            
        }
    }
    
}

struct FieldView: View {
    @ObservedObject var field:FluentGenerator.Field
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Name").font(.title2)
                    TextField("name", text: $field.name)
                }
                VStack(alignment: .leading) {
                    Text("Key").font(.title2)
                    TextField("key",text: $field.key)
                }
               
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("Type").font(.title2)
                    TextField("type",text: $field.type)
                }
                
                Toggle("Optional", isOn: $field.isOptional)
            }
            Divider()
        }
    }
}
