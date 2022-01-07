# Basic Lookup

The aim of basic search is to allow the agent to find potential customers that match the information that they have at hand, e.g. email, phone number, name.
As mentioned in the [Gladly tutorial](https://developer.gladly.com/tutorials/lookup) the initial search can be triggered automatically or by agent and because of that the Spree adapter accepts two different formats of requests.

## Manual Search Request
OOTB the extension allows searching by email, phone number and name of the customer. Additional fields can be added.

```json
{
  "lookupLevel":"BASIC",
  "uniqueMatchRequired":false,
  "query":{
    "emails":"customer@example.com",
    "phones":"666-666-666",
    "name": "Elka Melka",
  }
}
```

## Automatic Search Request
The request is automatically populated with data available in customer's profile. OOTB the extension searches for customers based on the name and emails (ignoring the rest of the fields).

```json
{
  "lookupLevel":"BASIC",
  "uniqueMatchRequired":false,
  "query":
    {
      "emails":["customer@example.com", "another@email.com"],
      "phones": ["666-666-666", "123-435-235"],
      "name": "Elka Melka",
      "lifetimeValue": "$500"
    }
}
```

## Basic Lookup Response

By default the fields listed below are returned. Fields can be hidden via Gladly UI or the integration
can be extended to return more/different fields ([Customization](/customization)). The format of the response has to match the [Gladly Customer schema](https://developer.gladly.com/rest/#operation/createCustomer)

Note: we use the email address as the `externalCustomerId` and not the id used by Spree.

```json
{
  "results":[
    {
      "externalCustomerId": "customer@example.com",
      "customAttributes": {
        "spreeId": 1
      },
      "name": "James Bond",
      "emails": [{"original": "customer@example.com"}],
      "phones": [{"original": "666-666-666"}],
      "address": "22 Apple Lane, 9999 San Francisco"
    }
  ]
}
```
