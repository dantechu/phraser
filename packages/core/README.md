## Intro

### Usage

- Register the dependency before using by:
  `CorePackage.registerDependencies();`
  Register once in the app where it's needed first.

### controllers
- connectivity controller to check internet connection

### userCases
- check string is question or not.

### models
- set question detector data to this model `InitialsForQuestionMarkModel()`

### services
- `InitialsForQuestionService()` used to fetch data from remote config.
