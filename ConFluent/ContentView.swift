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
  
    // model
    @ObservedObject var generator = FluentGenerator()
    
    // views
    var fieldsView: some View {
        VStack(alignment:.leading) {
            ForEach(generator.fields,
                    id:\.id) { field in
                FieldView(field: field)
            }
        }
    }

    var generateButton: some View {
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
    
    var addFieldButton: some View {
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
    
    var browseModelPathButton: some View {
        Button {
            open(type: FluentGenerator.FilePathType.model)
        } label: {
            Text("Browse")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var exportModelButton: some View {
        Button {
            //write to model path
        } label: {
            Text("Export")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var browseMigrationPathButton: some View {
        Button {
            open(type: FluentGenerator.FilePathType.migration)
        } label: {
            Text("Browse")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var exportMigrationButton: some View {
        Button {
            //write to migration path
        } label: {
            Text("Export")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var browseControllerPathButton: some View {
        Button {
            open(type: FluentGenerator.FilePathType.controller)
        } label: {
            Text("Browse")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var exportControllerButton: some View {
        Button {
            //write to controller path
        } label: {
            Text("Export")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var body: some View {
        HStack {
            VStack(alignment:.leading) {
                Text("Design")
                    .font(.title)
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
                Spacer()
                generateButton
                Spacer()
            }
            .padding()
            VStack(alignment:.leading) {
                Text("Model")
                    .font(.title)
                HStack {
                    browseModelPathButton
                    Text("\(generator.modelPath)")
                        .font(.title2)
                    exportModelButton
                }
                CodeEditor(source: $generator.generatedModel,
                           language: .swift)
                Text("Migration")
                    .font(.title)
                HStack {
                    browseMigrationPathButton
                    Text("\(generator.migrationPath)")
                        .font(.title2)
                    exportMigrationButton
                }
                CodeEditor(source: $generator.generatedMigration,
                           language: .swift)
                Text("Controller")
                    .font(.title)
                HStack {
                    browseControllerPathButton
                    Text("\(generator.controllerPath)")
                        .font(.title2)
                    exportControllerButton
                }
                CodeEditor(source: $generator.generatedController,
                           language: .swift)
            }
            .padding()
        }
    }
    
    func open(type:FluentGenerator.FilePathType) {
        
        let panel = NSOpenPanel()
               panel.allowsMultipleSelection = false
               panel.canChooseDirectories = true
        if panel.runModal() == .OK {
            switch type {
                
            case .model:
                generator.modelPath = panel.url?.absoluteString ?? ""
            case .migration:
                generator.migrationPath = panel.url?.absoluteString ?? ""
            case .controller:
                generator.controllerPath = panel.url?.absoluteString ?? ""
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
                TextField("name", text: $field.name)
                TextField("key",text: $field.key)
            }
            HStack {
                TextField("type",text: $field.type)
                Toggle("Optional", isOn: $field.isOptional)
            }
            Divider()
        }
    }
}
