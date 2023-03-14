# Action for [ideckia](https://ideckia.github.io/): memory

## Description

A memory game

## Properties

| Name | Type | Description | Shared | Default | Possible values |
| ----- |----- | ----- | ----- | ----- | ----- |
| rows | UInt | Rows | false | 2 | null |
| columns | UInt | Columns | false | 3 | null |
| item_text_size | UInt | Item text size | false | 30 | null |

## On single click

Open a new directory with item prepared to challenge your memory!

## On long press

Does nothing

## Test the action

There is a script called `test_action.js` to test the new action. Set the `props` variable in the script with the properties you want and run this command:

```
node test_action.js
```

## Example in layout file

```json
{
    "text": "memory action example",
    "actions": [
        {
            "name": "memory",
            "props": {
                "rows": 2,
                "columns": 3,
                "item_text_size": 30
            }
        }
    ]
}
```
