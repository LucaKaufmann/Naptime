//
//  framework.swift
//  ProjectDescriptionHelpers
//
//  Created by Luca Kaufmann on 18.8.2023.
//

import ProjectDescription

let frameworkName: Template.Attribute = .required("name")


let frameworkTemplate = Template(
    description: "Framework template",
    attributes: [
        frameworkName
    ], items: [
        .file(
            path: "modules/\(frameworkName)/Project.swift",
            templatePath: "project.stencil"
        ),
        .string(path: "modules/\(frameworkName)/src/implementation.swift", contents: "// Module \(frameworkName)\nimport Foundation"),
        .string(path: "modules/\(frameworkName)/interface/interface.swift", contents: "// Module \(frameworkName)\nimport Foundation"),
        .string(path: "modules/\(frameworkName)/resources/Resources.md",
                        contents: "# Add resources here")    ]
)
