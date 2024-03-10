# TechTicksAssignment

### About

An engaging and intuitive task management app designed for iOS.

See [Tech Assignment - iOS.pdf](Documentation/Tech Assignment - iOS.pdf) for specifications.

# Documentation

### App Architecture

The app uses classic MVC architecture as represented below.

<div align="center">
  <img src="Documentation/MVC Architecture.png" width="500">
</div>

This is broken down more in the **System Design** section.

### System Design

This is a high level overview of the system design.  You can see how the layers and flow of data matches the MVC architecture diagram above. Descriptions on the purposes of each of the structures shown are documented as class headers in-code.

<div align="center">
  <img src="Documentation/System Design.png" width="700">
</div>

### Core Data Model

The core data model is very simple. As it's only required to store tasks, that's the only entity. Derived and calculated task properties such as `status` (ongoing, upcoming, completed) are defined in the `Task` class to be calculated in real time and hence aren't persisted. All properties are marked non-optional.

<div align="center">
  <img src="Documentation/Core Data Model.png" width="300">
</div>

### Libraries

No external libraries were used. The app uses the system frameworks Foundation, UIKit, and Core Data.
