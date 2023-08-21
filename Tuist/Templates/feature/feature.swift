//
//  framework.swift
//  ProjectDescriptionHelpers
//
//  Created by Luca Kaufmann on 18.8.2023.
//

import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")


let template = Template(
    description: "Framework template",
    attributes: [
        nameAttribute
    ], items: [
        .file(
            path: "modules/\(nameAttribute)/Project.swift",
            templatePath: "project.stencil"
        ),
        .file(
            path: "modules/\(nameAttribute)/app/\(nameAttribute)App.swift",
            templatePath: "app.stencil"
        ),
        .file(
            path: "modules/\(nameAttribute)/app/ContentView.swift",
            templatePath: "ContentView.stencil"
        ),
        .string(path: "modules/\(nameAttribute)/src/implementation.swift", contents: "// Module \(nameAttribute)\nimport Foundation"),
        .string(path: "modules/\(nameAttribute)/interface/interface.swift", contents: "// Module \(nameAttribute)\nimport Foundation"),
        .string(path: "modules/\(nameAttribute)/resources/Resources.md",
                        contents: "# Add resources here")    ]
)
