## Intro

A package to interact with OpenAI API. Logs and reads interactions of a user from local DB.

### Usage

- Register the dependency before using by:
  `AIInteractionsPackage.registerDependencies();`
  Register once in the app where it's needed first.
- Use `AIInteractionsContoller` to interact with the layer.
- To Fetch Interaction History use `InteractionsHistoryUseCases().getLocalHistory()`

### UserCases

- Get API configs from RemoteConfigs
- Get API Respose from user's message

### UI

- N/A

### TODO

- Move Mic UI and Logic to this package
- Move question and answer formatting to this package

### Examples

- Dummy interaction with premade message to the API
- Fetch Chat history
