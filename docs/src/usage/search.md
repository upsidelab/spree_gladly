# How does the search work? What do the fields mean?

It's worth noting that in Spree customers are able to create orders without being logged in. It is important to be able to link such customers with their Gladly profiles to be able to help them.
This slightly complicates the search and makes it worth an explanation. Since we want to be able to identify both registered customers and customers with only guest orders, we are using the email address instead of the `Spree::Account.id` as `externalCustomerId` in Gladly (the unique identifier of a customer in an external system).

Note details on the exact format of the jsons was shown in previous section. The below tables are for information of the meaning of the fields in Spree.

## Basic search

As mentioned in [Basic Lookup](#basic-lookup) searching by name, emails and phone numbers is possible.
To simplify the search logic and improve performance, searching by name and phone number will only search customers with Spree profiles.
Searching by email searches both registered customers and guest orders. It happens in two phases (for each customer's email separately):

1. Attempt to find any customers with a Spree profile with the given email. If found, search will return that customer.
2. If no customer is found the search will attempt to find all orders associated with the given email. If multiple orders are found it will return the details of the latest (`completed_at`) order.

Below table explains the returned fields.

**For registered customers:**

| Gladly customer field    | Spree field                                                   |
| ------------------------ | ------------------------------------------------------------- |
| name                     | Spree::User.bill_address.full_name                            |
| externalCustomerId       | Spree::User.email                                             |
| emails                   | Spree::User.email                                             |
| customAttributes.spreeId | Spree::User.id                                                |
| phones                   | Spree::User.bill_address.phone                                |
| address                  | Spree::User.bill_address (address1, address2, city,  zipcode) |

**For guest customers**

In the below table Spree::Order means the latest (`Spree::Order.completed_at`) order that matched the email from the search.

| Gladly field             | Spree                                                         |
| ------------------------ | ------------------------------------------------------------- |
| name                     | Spree::Order.bill_address.full_name                           |
| externalCustomerId       | Spree::Order.email                                            |
| emails                   | Spree::Order.email                                            |
| customAttributes.spreeId | -                                                             |
| phones                   | Spree:Order.bill_address.phone                                |
| address                  | Spree::Order.bill_address.(address1, address2, city, zipcode) |

## Detailed search

Detailed search assumes that we have found the right customer and we know their unique identifier. In Gladly this is the `externalCustomerId` and in Spree, it's equivalent to the email address.

The below tables list the fields returned from Spree.

**For registered customers:**

| Gladly field                     | Spree field                                                                   |
| -------------------------------- | ----------------------------------------------------------------------------- |
| name                             | Spree::User.bill_address.full_name                                            |
| externalCustomerId               | Spree::User.email                                                             |
| emails                           | Spree::User.email                                                             |
| phones                           | Spree::User.bill_address.phone                                                |
| address                          | Spree::User.bill_address.(address1 , address2, city, zipcode)                 |
| customAttributes.spreeId         | Spree::User.id                                                                |
| customAttributes.totalOrderCount | total of Spree::Order(s) that match the `externalCustomerId`                  |
| customAttributes.guestOrderCount | customAttributes.totalOrderCount - Spree::Account.attributes.completed_orders |
| customAttributes.memberSince     | Spree::User.created_at                                                        |
| customAttributes.customerLink    | customer_profile_url(Spree::User)                                             |
| customAttributes.lifetimeValue   | sum `total` field of Spree::Order(s) that match the `externalCustomerId`      |
| transactions                     | details of all Spree::Orders that match the `externalCustomerId`              |

**For guest customers**

| Gladly field                     | Spree field                                                              |
| -------------------------------- | ------------------------------------------------------------------------ |
| name                             | -                                                                        |
| externalCustomerId               | Spree::User.email                                                        |
| emails                           | Spree::User.email                                                        |
| phones                           | -                                                                        |
| address                          | -                                                                        |
| customAttributes.spreeId         | -                                                                        |
| customAttributes.totalOrderCount | total of Spree::Orders that match the `externalCustomerId`               |
| customAttributes.guestOrderCount | customAttributes.totalOrderCount                                         |
| customAttributes.memberSince     | -                                                                        |
| customAttributes.customerLink    | -                                                                        |
| customAttributes.lifetimeValue   | sum `total` field of Spree::Order(s) that match the `externalCustomerId` |
| transactions                     | details of all Spree::Orders that match the `externalCustomerId`         |
