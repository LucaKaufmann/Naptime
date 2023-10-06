# Naptime

Naptime is a simple, modular SwiftUI app to keep track of your baby's (or your) sleep. The app supports Live activities to view current naps or awake windows at a glance and features syncing across multiple devices using iCloud.
This repository serves as an example for a modular app using the micro feature and feature apps architecture. 



## Frameworks
Features are written in The Composable Architecture (TCA) and the app uses Tuist for generating all the project files.
CoreData is used for persistence, CloudKit and CloudKit zone sharing are supported for syncing entries across devices.

![Diagram showing dependencies of different frameworks and targets](https://github.com/LucaKaufmann/Naptime/blob/main/graph.png)


## Get started

- Install Tuist ([docs.tuist.io](https://docs.tuist.io/tutorial/get-started/))
- Clone repository `git clone git@github.com:LucaKaufmann/Naptime.git`
- `cd Naptime`
- Fetch dependencies in Tuist `tuist fetch`
- Generate project `tuist generate`

Manually setting up code signing (or selecting Xcode Managed) might be necessary to run the app.

### Focus on feature

See steps above for initial setup.
To only generate a specific feature, run `tuist generate [Feature_name]`. For example `tuist generate NaptimeStatistics`

Manually setting up code signing (or selecting Xcode Managed) might be necessary to run the app.

## Create new feature

A Tuist template exists to add a new feature. It takes care of setting up the appropriate targets, including the feature app target. Some information needs to be edited, like adding all the necessary dependencies and adding the feature into the ContentView of the feature app. These are roughtly the steps needed to add new features:

- Run `tuist scaffold feature --name [Feature_name]`
- Open tuist `tuist edit`
- Add microfeature to `Feature` enum in `Manifests/Tuist/ProjectDescriptionHelpers/Project+Microfeature.swift` 
- Find feature under `Manifests/modules/Feature_name`
- In `Project.swift` add necessary dependencies that are used in that feature
- Close Xcode and press `CTRL+C` to save Tuist files
- run `tuist generate` to generate new project
