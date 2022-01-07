# Detailed Lookup

Detailed lookup is used to update the linked customer with detailed data. This means that detailed lookup expects only one result returned. Gladly will send in the request all the customer's information except transactions. However, only the `externalCustomerId` is used to find the correct customer in Spree.

**request payload:**

```json
{
  "lookupLevel":"DETAILED",
  "uniqueMatchRequired":true,
  "query":{
    "name": "Some name",
    "totalOrderCount": "4",
    "emails":[ "customer@example.com", "another@email.com"],
    "phones":[
      "666-666-666"
    ],
    "externalCustomerId":"customer@example.com",
    "customAttributes": {
      "spreeId": 1
    }
  }
}
```

**response payload:**
The following payload shows all the fields that are by default returned from Spree. You can ask your Gladly representative to amend which fields are visible in the order card or the integration can be extended to return more/different fields ([Customization](/customization))

```json
{
  "results":[
    {
      "externalCustomerId": "customer@example.com",
      "name":"James Bond",
      "address":"Baker Street 007 London, AK 00021 United Kingdom",
      "emails":[
        {
          "original":"customer@example.com"
        }
      ],
      "phones":[
        {
          "original":"666-666-666"
        }
      ],
      "customAttributes":{
        "spreeId": "4",
        "lifetimeValue":"$142.97",
        "totalOrderCount":"2",
        "guestOrderCount": "0",
        "memberSince" : "May 17, 2021 10:18 AM UTC",
        "customerLink": "https://example-spree-store.com/admin/users/4/edit"
      },
      "transactions":[
        {
          "type":"ORDER",
          "orderStatus":"complete",
          "orderNumber":"R185194841",
          "orderLink":"https://example-spree-store.com/admin/orders/R185194841/edit",
          "note":"",
          "orderTotal":"$83.99",
          "createdAt":"2021-06-21T10:29:43.881Z",
          "products":[
            {
              "name":"Flared Midi Skirt",
              "status":"fulfilled",
              "sku": "SKU-1",
              "quantity":"1",
              "unitPrice":"$78.99",
              "total": "$78.99",
              "imageUrl":""
            }
          ]
        },
        {
          "type":"ORDER",
          "orderStatus":"complete",
          "orderNumber":"R461455233",
          "orderLink":"https://example-spree-store.com/admin/orders/R461455233/edit",
          "note":"Some note about the order",
          "orderTotal":"$58.98",
          "createdAt":"2021-06-21T10:34:10.262Z",
          "products":[
            {
              "name":"3 4 Sleeve T Shirt",
              "status":"fulfilled",
              "sku": "SKU-2",
              "quantity":"2",
              "unitPrice":"$26.99",
              "total": "$53.98",
              "imageUrl":"https://example-spree-store.com/images/sample_picture.jpg"
            }
          ]
        }
      ]
    }
  ]
}
```
