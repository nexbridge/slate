---
title: Nexbridge API

language_tabs:
  - PHP

search: true
---

# Introduction

Welcome to the Nexbridge API, which can be used to access a range of management information, account data and administrative functions. This is the API used by the My Nexbridge portal, so everything you can do on My Nexbridge can also be done via this API.

The root URL can be found at:

`https://api.nexbridge.co.uk/v1/`

# Authentication

User authentication is done via **Basic Auth** over **HTTPS** with a **username** and **password**.  The `Authorization` header has the following standard format:

`Authorization: Basic `*`[encoded string]`*

The encoded string is just the username and password separated by a colon and then `base64` encoded.  The example API request function given in the next section generates this for you.

<aside class='notice'>This is a private API for Nexbridge customers only, so you will need to send us your IP address so that we can allow you access.</aside>

# Requests and responses

> Example API request function using cURL

```php
<?php
/**
 * @param string $username
 * @param string $password
 * @param string $object
 * @param string $action
 * @param array $parameters
 */
function API_request($username, $password, $object = NULL, $action = NULL, $parameters = array())
{
	$URL = "https://api.nexbridge.co.uk/v1/" . $object;
	
	$ch = curl_init();
	
	if ($action)
	{
		$URL .= "/" . $action;
		
		switch ($action)
		{
		case "download":
		case "enumerate":
		case "view":
			$URL .= "?" . http_build_query($parameters);
			break;
			
		case "add":
		case "reset":
			curl_setopt($ch, CURLOPT_POST, true);
			curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($parameters));
			break;
			
		case "edit":
			curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
			curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($parameters));
			break;
			
		case "remove":
			curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
			curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($parameters));
			break;
			
		default:
			/* Handle unexpected action */
		}
	}
	
	curl_setopt($ch, CURLOPT_HTTPHEADER, array("Accept: application/json"));
	curl_setopt($ch, CURLOPT_URL, $URL);
	curl_setopt($ch, CURLOPT_USERPWD, $username . ":" . $password);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	
	$result = curl_exec($ch);
	
	if ($result === false)
	{
		$curlError = curl_error($ch);
	}
	else
	{
		$HTTPcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
		$contentType = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
	}
	
	curl_close($ch);
	
	if (!isset($curlError))
	{
		if ($HTTPcode == 200)
		{
			switch (strtok($contentType, ";"))
			{
			case "application/json":
				/* Handle JSON response */
			
			case "application/pdf":
				/* Handle PDF download */
			
			case "application/xml":
				/* Handle XML response */
			
			case "audio/mpeg":
				/* Handle MP3 download */
			
			case "text/html":
				/* Handle HTML response */
				
			default:
				/* Handle unexpected content type */
			}
		}
		else
		{
			/* Handle HTTP error */
		}
	}
	else
	{
		/* Handle cURL error */
	}
}
```

> Example object request function

```php
<?php
/**
 * @param string $username
 * @param string $password
 */
function remove_contact($username, $password)
{
	$parameters["objectID"] = 1;
	
	API_request($username, $password, "Contact", "remove", $parameters);
}
```

> Example actionless request function

```php
<?php
/**
 * @param string $username
 * @param string $password
 */
function get_contact_info($username, $password)
{
	API_request($username, $password, "Contact");
}
```

> Example objectless request function

```php
<?php
/**
 * @param string $username
 * @param string $password
 */
function get_all_info($username, $password)
{
	API_request($username, $password);
}
```

This section provides basic information regarding API requests and responses.  An example API request function is given on the right.

### Requests

The general format for requests includes both an **object** and an **action**, e.g.

`/Password/reset`

`/ReportDistribution/add`

`/SFTPdetails/edit`

`/User/remove`

<aside class='notice'>Objects are capitalised, but actions are not.</aside>

You can also make an **actionless** request, which returns any [dynamic information](#dynamic-object-information) for the given object, e.g.

`/OutboundRates`

or even an **objectless** request, which returns any [dynamic information](#dynamic-object-information) for all available objects:

`/`

<aside class='notice'>Any <b>dynamic</b> information should be obtained via an objectless/actionless request.</aside>

A description of the actions available in this API and the request methods to use in each case is given below. Which actions are available will depend on the object, and this is specified [dynamically](#dynamic-object-information).

Action      | Description                                                              | Request&nbsp;method
----------- | ------------------------------------------------------------------------ | -------------------
`add`       | Adds a new instance of the object                                        | `POST`
`download`  | Downloads an instance of the object                                      | `GET`
`edit`      | Edits an instance of the object                                          | `PUT`
`enumerate` | Lists the available values for enumerable fields belonging to the object | `GET`
`remove`    | Removes an instance of the object                                        | `DELETE`
`reset`     | Resets an instance of the object                                         | `POST`
`view`      | Lists existing instances of the object                                   | `GET`

All actionless/objectless requests should use the `GET` request method.

In the case of `GET` requests where an action is specified, it should then be followed by a query, e.g.

`/CallSummary/view?limit=10&offset=0`

`/CallRecording/download?objectID=1`

For further information regarding the query format for `view` requests, see [Pagination, filters and sorts](#pagination-filters-and-sorts).

For all request methods other than `GET`, any data should be included in the post fields rather than in the query.

The example API request function on the right generates the correct request method in all cases and includes the data in the query or post fields as required.

### Responses

Any request rejected by the web server (rather than by the API) will receive one of the standard HTTP error responses.  Any request that reaches the API endpoint successfully will **always** receive a HTTP status code of 200, with custom **API codes** then being used to indicate the result of the request whenever a JSON/XML response is returned (see below).  The format of the response will depend on the type of request and will be specified by the `Content-Type` header, so once you've checked the HTTP status code for success this header should be used to determine how to handle the response, as illustrated in the example API request function on the right.  The formats used in this API are as follows:

* PDFs are returned as `application/pdf`;
* MP3s are returned as `audio/mpeg`;
* All other responses are returned as `application/json` by default, unless you specify `application/xml` in the `Accept` header of the request.

The top-level structure of the JSON/XML responses is given below:

Name           | Description                                     | Array | Always&nbsp;provided
-------------- | ----------------------------------------------- | ----- | --------------------
`APIcode`      | API code                                        | No    | Yes
`errorMessage` | Error message                                   | No    | No
`result`       | Information provided as a result of the request | Yes   | No

For further details regarding the information contained in `result`, see [Objects](#objects).  A description of the API codes is given below:

* An API code of **200** indicates success, and any other API code signals an error, in which case `errorMessage` will be populated;
* An API code of **400** indicates an error that should have been handled client-side, i.e. should never have been sent to the API in the first place;
* An API code of **500** indicates a server-side error;
* An API code between **401** and **499** inclusive indicates a client-side error that can’t necessarily be identified client-side and thus must be done server-side.  The API codes given in the table below can be returned for any request; the others are object-specific and given in the [individual object descriptions](#objects).

API&nbsp;code | Description
------------- | -----------
401           | Password incorrect
402           | Password expired
403           | Password not yet set
404           | User does not exist
405           | User de-activated

# Data types and validation

> Barred telephone number range check (list of barred ranges provided dynamically)

```php
<?php
/** 
 * @param string $number
 * @param array $barredRanges
 *
 * @return bool
 */
function is_barred_number($number, $barredRanges)
{
	foreach ($barredRanges as $range)
	{
		if (substr($number, 0, strlen($range)) === $range)
		{
			return true;
		}
	}
	
	return false;
}
```

> Email address validation

```php
<?php
/** 
 * @param string $email
 *
 * @return bool
 */
function is_email_address($email)
{
	if (filter_var($email, FILTER_VALIDATE_EMAIL))
	{
		return true;
	}
	else
	{
		return false;
	}
}
```

> Name validation

```php
<?php
/** 
 * @param string $name
 *
 * @return bool
 */
function is_name($name)
{
    if (preg_match("/^\p{Latin}+$/u", (str_replace(array("-", "'", " "), "", $name))))
    {
		return true;
	}
	else
	{
		return false;
	}
}
```

> Network host validation

```php
<?php
/** 
 * @param string $host
 *
 * @return bool
 */
function is_network_host($host)
{
	/* If host is valid IPv4 address */
	if (filter_var($host, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4))
	{
		return true;
	}
	
	/* If host invalid */
	if (!filter_var("test@" . $host, FILTER_VALIDATE_EMAIL))
	{
		return false;
	}
	
	$DNSrecord = dns_get_record($host, DNS_A);
	
	/* If host fails DNS resolution */
	if (!$DNSrecord)
	{
		return false;
	}
	
	return true;
}
```

> Postcode validation (maximum length provided dynamically)

```php
<?php
/** 
 * @param string $postcode
 * @param string $country
 * @param int $maxLength
 *
 * @return bool
 */
function is_postcode($postcode, $country, $maxLength)
{
	/* If country does not use UK postcode format */
	if (!in_array($country, array("Guernsey", "Isle Of Man", "Jersey", "United Kingdom")))
	{
		if (strlen($postcode) > $maxLength)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	
	/* Remove any spaces and convert to upper case */
	$postcode = strtoupper(str_replace(" ", "", $postcode));
	
	/* Validate postcode format */
	switch (strlen($postcode))
	{
	case 5:
		if (!preg_match("/[A-Z][0-9][0-9][A-Z][A-Z]/", $postcode))
		{
			return false;
		}
		
		break;
		
	case 6:
		if (!preg_match("/[A-Z][0-9A-Z][0-9A-Z][0-9][A-Z][A-Z]/", $postcode))
		{
			return false;
		}
		
		if (preg_match("/[A-Z][A-Z]/", substr($postcode, 1, 2)))
		{
			return false;
		}
		
		break;
		
	case 7:
		if (!preg_match("/[A-Z][A-Z][0-9][0-9A-Z][0-9][A-Z][A-Z]/", $postcode))
		{
			return false;
		}
		
		break;
		
	default:
		return false;
	}
	
	return true;
}
```

> Reserved IP address check (list of reserved CIDR ranges provided dynamically)

```php
<?php
/** 
 * @param string $IP
 * @param array $reservedCIDRranges
 *
 * @return bool
 */
function is_reserved_IP($IP, $reservedCIDRranges)
{
	/* Convert IP address to its long integer representation */
	$IPlong = ip2long($IP);
	
	foreach ($reservedCIDRranges as $CIDRrange)
	{
		/* Break down CIDR notation into its component parts */
		$rangeSubnet = strtok($CIDRrange, "/");
		$bits = strtok("");
		
		/* Convert range subnet to its long integer representation */
		$rangeSubnetLong = ip2long($rangeSubnet);
		
		/* Get subnet mask */
		$mask = -1 << (32 - $bits);
		
		/* In case range subnet was incorrectly aligned */
		$rangeSubnetLong = $rangeSubnetLong & $mask;
		
		/* Get equivalent subnet of IP address in its long integer representation */
		$IPsubnetLong = $IPlong & $mask;
		
		/* If IP address in reserved range */
		if ($IPsubnetLong == $rangeSubnetLong)
		{
			return true;
		}
	}
	
	return false;
}
```

> Basic telephone number validation (length restrictions provided dynamically)

```php
<?php
/** 
 * @param string $number
 * @param int $minLength
 * @param int $maxLength
 *
 * @return bool
 */
function is_telephone_number($number, $minLength, $maxLength)
{
	/* Remove any spaces */
	$number = str_replace(" ", "", $number);
	
	/* Convert to E.164 standard format */
	
	if (substr($number, 0, 2) === "00")
	{
		$number = "+" . substr($number, 2);
	}
	else if (substr($number, 0, 1) === "0")
	{
		$number = "+44" . substr($number, 1);
	}
	else if (substr($number, 0, 2) === "44")
	{
		$number = "+" . $number;
	}
	else if (substr($number, 0, 1) !== "+")
	{
		/* If prefix invalid */
		return false;
	}
	
	/* If number not comprised of digits */
	if (!ctype_digit(substr($number, 1)))
	{
		return false;
	}
	
	$length = strlen($number);
	
	/* If UK number */
	if (substr($number, 0, 3) === "+44")
	{
		/* If non-standard length (a few shorter numbers do exist, but it's much more likely to be a missing digit) */
		if ($length != 13)
		{
			return false;
		}
	}
	else
	{
		/* If invalid length or invalid prefix */
		if ($length < $minLength || $length > $maxLength || substr($number, 0, 2) === "+0")
		{
			return false;
		}
	}
	
	return true;
}
```

This section provides details regarding the data types that are used in this API, which define what format to expect in the response and (where applicable) what client-side validation is expected prior to making the request.  Where the exact validation required is not obvious, the server-side validation code is given on the right so that you can write your client-side validation to match.

A description of each data type is given below, along with any [dynamic properties](#dynamic-field-properties) available for that type (N.B. these properties are only specified for [object fields](#fields)):

Data&nbsp;type    | Dynamic&nbsp;properties                | Description/format
----------------- | -------------------------------------- | ------------------
`alphanumeric`    | `maxLength`                            | Alphanumeric text
`boolean`         |                                        | Boolean value
`CIDR`            |                                        | IPv4 range given in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation
`date`            | `max`, `min`                           | YYYY-MM-DD
`decimal`         | `decimalPlaces`, `maxDigits`, `signed` | Decimal number
`email`           | `maxLength`                            | Email address
`enum`            |                                        | Enumerable list obtainable via an `enumerate` action
`host`            | `maxLength`                            | Network host that does not belong to a reserved range
`integer`         | `max`, `min`                           | Integer number
`IP`              |                                        | IPv4 address
`month`           | `max`, `min`                           | YYYY-MM
`name`            | `maxLength`                            | Person's name
`password`        | `minLength`                            | Password with at least one non-alphabetic character
`phone`           | `maxLength`\*, `minLength`\*           | Telephone number
`phoneRange`      |                                        | Telephone number range
`postcode`        | `maxLength`                            | Postcode
`restrictedPhone` | `maxLength`\*, `minLength`\*           | UK 01/02/03/080 telephone number
`routablePhone`   | `maxLength`\*, `minLength`\*           | Telephone number that does not belong to a barred range
`text`            | `maxLength`                            | Generic text
`timestamp`       | `max`, `min`                           | YYYY-MM-DD HH:MM:SS

\* When in [E.164](https://en.wikipedia.org/wiki/E.164) standard format with a leading plus

# Pagination, filters and sorts

> Example view request function

```php
<?php
/**
 * @param string $username
 * @param string $password
 */
function view_users($username, $password)
{
	$parameters["limit"] = 10;
	$parameters["offset"] = 0;
	
	API_request($username, $password, "User", "view", $parameters);
}
```

> Example view request function with filters

```php
<?php
/**
 * @param string $username
 * @param string $password
 */
function view_call_summary($username, $password)
{
	$parameters["filters"] = array("prefix,eq,441", "prefix,eq,442");
	$parameters["limit"] = 10;
	$parameters["offset"] = 0;
	
	return API_request($username, $password, "CallSummary", "view", $parameters);
}
```

> Example view request function with sorts

```php
<?php
/**
 * @param string $username
 * @param string $password
 */
function view_contacts($username, $password)
{
	$parameters["sorts"] = array("surname" => "desc", "forename" => "asc");
	$parameters["limit"] = 10;
	$parameters["offset"] = 0;
	
	return API_request($username, $password, "Contact", "view", $parameters);
}
```

This section provides details regarding the functionality available for `view` requests and the query format required.  Example request functions are given on the right, using the general API request function given [earlier](#requests-and-responses).

### Pagination

All `view` requests require a `limit` and `offset` to be specified, which you can use for pagination purposes.

Name     | [Data&nbsp;type](#data-types-and-validation) | Min. | Max.
-------- | -------------------------------------------- | ---- | ----
`limit`  | `integer`                                    | 1    | 1000
`offset` | `integer`                                    | 0    | None

For example, to view 10 results per page,

`/User/view?limit=10&offset=0`

would list the results for the first page,

`/User/view?limit=10&offset=10`

would list the results for the second page, and so on.  The total number of results available is also returned each time under `result`&rarr;`totalAvailable` so that you can calculate the total number of pages.

### Filters

Filters can be added to the query of a `view` request to specify restrictions on the data you wish to receive.  Each filter is comprised of 3 elements:

* The **field** you wish to apply the filter to;
* The **operator** you wish to be used;
* The **value** you wish to filter by.

These 3 elements should then be comma-separated as follows:

*`[field],[operator],[value]`*

and added into an array named `filters` in the query.  The operator is designated by a two-letter short code, as listed in the table below.  The **combination method** indicates how multiple filters of the **same** field are combined, e.g.

`/Invoice/view?filters[]=date,ge,2017-01-01&filters[]=date,le,2017-01-15&limit=10&offset=0`

returns results where `date >= 2017-01-01` **and** `date <= 2017-01-15`, whereas

`/CallSummary/view?filters[]=prefix,eq,441&filters[]=prefix,eq,442&limit=10&offset=0`

returns results where `prefix = 441` **or** `prefix = 442`.

Operator | Description              | Combination&nbsp;method
-------- | ------------------------ | -----------------------
eq       | Equal to                 | OR
ne       | Not equal to             | AND
lt       | Less than                | AND
gt       | Greater than             | AND
le       | Less than or equal to    | AND
ge       | Greater than or equal to | AND
bw       | Begins with              | OR
db       | Does not begin with      | AND
ew       | Ends with                | OR
de       | Does not end with        | AND
co       | Contains                 | OR
dc       | Does not contain         | AND

### Sorts

Sorts can be added to the query of a `view` request to sort the results by any one of its fields in **ascending** or **descending** order.  They should be added as an array of key-value pairs named `sorts`, with the field as the key, and `asc` or `desc` as the value.  These will then be applied in the order they are given in the query, e.g.

`/Contact/view?sorts[surname]=desc&sorts[forename]=asc&limit=10&offset=0`

will sort the results **first** by `surname` descending, **then** by `forename` ascending.  

<aside class='notice'>Any <b>empty</b> values in a sorted field will always be listed last, regardless of whether the sort was ascending or descending.</aside>

# Objects

## Introduction

This section provides details of the objects available to customers using this API.

### Fields

Each individual object description includes details of the fields that are either required or returned by the object for certain actions.

* Returned field values are always contained in `result`&rarr;`data`.
* Required fields are not nullable unless otherwise specified; if a required field is nullable then that means it must be present in the request but its value can be an empty string.

### Dynamic object information

The following information can be requested [dynamically](#requests) for any object and is returned under `result`&rarr;*`[object]`*:

Name               | Description                                   | Array
------------------ | --------------------------------------------- | -----
`availableActions` | Contains the actions available for the object | Yes
`fields`           | Contains any dynamic properties of the fields | Yes

Any additional object-specific dynamic information is listed in the individual object descriptions.

### Dynamic field properties

Each dynamic field property has a scalar (i.e. non-array) value, and is returned under `result`&rarr;*`[object]`*&rarr;`fields`&rarr;*`[field]`*&rarr;*`[property]`*.  A description of each property is given below:

Property        | [Data&nbsp;type](#data-types-and-validation) | Description
----------------| -------------------------------------------- | -----------
`decimalPlaces` | `integer`                                    | The number of digits allowed after the decimal point
`max`           | Same&nbsp;as&nbsp;the&nbsp;field             | The maximum value allowed
`maxDigits`     | `integer`                                    | The maximum number of digits allowed, including the decimal places (but not the decimal point)
`maxLength`     | `integer`                                    | The maximum number of characters allowed
`min`           | Same&nbsp;as&nbsp;the&nbsp;field             | The minimum value allowed
`minLength`     | `integer`                                    | The minimum number of characters allowed
`nullable`      | `boolean`                                    | `true` if the field can be empty, or `false` otherwise
`signed`        | `boolean`                                    | `true` if negative values are allowed, or `false` otherwise
`type`          | `text`                                       | The data type of the field

* The `nullable` property is specified for all object fields returned by a `view` action.
* The `type` property is specified for all object fields, and determines which other properties are specified (if any).

### Enumerate action

The `enumerate` action is available for all object fields whose [data type](#data-types-and-validation) is `enum`.  The fields you wish to enumerate should be specified in an array named `fields` in the query, e.g.

`/Contact/enumerate?fields[]=title&fields[]=type`

The resulting enumerated list for each field is then returned under `result`&rarr;*`[field]`*.

### Compliance confirmation

Certain object actions require compliance confirmation relating to the use of telephone numbers for outbound presentation (CLIs).  By confirming compliance as part of a given API request you are confirming the relevant compliance criteria, which vary based on the type of telephone number involved and whether it is hosted on our network, as defined below:

1. The calls will be made for or on behalf of a company that is based either at or as near as possible to the geographical location corresponding to the area code of this CLI.
2. The end user who will be originating the calls is authorised by the range holder to present this CLI on our network.
3. There are sufficient inbound facilities in place to be able to handle the volume of calls generated by the corresponding outbound from this CLI.
4. This CLI will be used in a manner that is compliant with the [National Telephone Numbering Plan](https://www.ofcom.org.uk/siteassets/resources/documents/phones-telecoms-and-internet/information-for-industry/numbering/other/national-numbering-plan.pdf) and [Ofcom General Conditions](https://www.ofcom.org.uk/phones-and-broadband/accessibility/general-conditions-of-entitlement/) B1 and C6.
5. This CLI will either be [TPS](https://en.wikipedia.org/wiki/Telephone_Preference_Service) screened or will not be used to make unsolicited sales/marketing calls to UK destinations.
6. This CLI will not be used to make unsolicited sales/marketing calls to UK destinations.
7. This CLI will not be used to make sales/marketing calls of any kind (including opt-in), nor for financial services or customer service/support lines within the UK.
8. The end user is either based in the country corresponding to this CLI or, if not, this CLI will not be used to make calls to UK destinations.

Type of telephone number  | Relevant compliance criteria
------------------------- | ----------------------------
Hosted UK 01/02 CLI       | 1, 4, 5
Non-hosted UK 01/02 CLI   | 1, 2, 3, 4, 5
Hosted UK 03/080 CLI      | 4, 5
Non-hosted UK 03/080 CLI  | 2, 3, 4, 5
Hosted UK 084/087 CLI     | 4, 7
Non-hosted UK 084/087 CLI | 2, 3, 4, 7
Non-hosted non-UK CLI     | 2, 3, 4, 6, 8

## Access Charges

This object provides information regarding network access charges.

### URL

`/AccessCharges`

### Fields

Name          | Description        | Required&nbsp;for | Returned&nbsp;by
------------- | ------------------ | ----------------- | ----------------
`customerID`  | Customer&nbsp;ID   | `view`            | 
`description` | Charge description |                   | `view`
`month`       | Month              | `view`            |
`PPCday`      | PPC&nbsp;daytime   |                   | `view`
`PPCeve`      | PPC&nbsp;evening   |                   | `view`
`PPCwkd`      | PPC&nbsp;weekend   |                   | `view`
`PPMday`      | PPM&nbsp;daytime   |                   | `view`
`PPMeve`      | PPM&nbsp;evening   |                   | `view`
`PPMwkd`      | PPM&nbsp;weekend   |                   | `view`

### Additional dynamic information

The following additional information is provided [dynamically](#requests):

Name               | Description                                                        | [Data&nbsp;type](#data-types-and-validation) | Array
------------------ | ------------------------------------------------------------------ | -------------------------------------------- | -----
`rateCardIssueDay` | Day of the month the following month's rate card is made available | `integer`                                    | No

## Account Settings

This object handles customer account settings.

### URL

`/AccountSettings`

### Fields

Name               | Description             | Required&nbsp;for | Returned&nbsp;by
------------------ | ----------------------- | ----------------- | ----------------
`customerID`       | Customer&nbsp;ID        | `edit`            | `view`
`issueProformas`   | See notes               | `edit`            | `view`
`paymentMethod`    | Payment method          |                   | `view`
`referenceName`    | Customer reference name |                   | `view`
`VATrate`          | VAT rate                |                   | `view`
`VATreverseCharge` | VAT reverse charge      |                   | `view`

### Notes

The `issueProformas` field determines whether proformas are issued to the relevant accounts contacts on receipt of payments, and is only populated (and thus an `edit` request is only accepted) where the `paymentMethod` value is 'pre-payment'.

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description         | Returned&nbsp;by
------------- | ------------------- | ----------------
418           | No changes effected | `edit`

## Balance

This object provides information regarding the current account balance.

### URL

`/Balance`

### Fields
		
Name               | Description                | Required&nbsp;for | Returned&nbsp;by
------------------ | -------------------------- | ----------------- | ----------------
`active`           | See notes                  |                   | `view`
`balanceAvailable` | Balance available&nbsp;(£) |                   | `view`
`creditLimit`      | Credit limit&nbsp;(£)      |                   | `view`
`customerID`       | Customer&nbsp;ID           |                   | `view`
`referenceName`    | Customer reference name    |                   | `view`

### Notes

The `active` field specifies whether traffic is currently allowed to route for the customer.

### Additional dynamic information

The following additional information is provided [dynamically](#requests):

Name              | Description                                                   | [Data&nbsp;type](#data-types-and-validation) | Array
----------------- | ------------------------------------------------------------- | -------------------------------------------- | -----
`updateFrequency` | How often the `balanceAvailable` field is updated, in minutes | `integer`                                    | No

## Billing Address

This object provides the billing address currently used on invoices.

### URL

`/BillingAddress`

### Fields

Name            | Description             | Required&nbsp;for | Returned&nbsp;by
--------------- | ----------------------- | ----------------- | ----------------
`addressLine1`  | Address line&nbsp;1     |                   | `view`
`addressLine2`  | Address line&nbsp;2     |                   | `view`
`addressLine3`  | Address line&nbsp;3     |                   | `view`
`addressLine4`  | Address line&nbsp;4     |                   | `view`
`billingName`   | Customer billing name   |                   | `view`
`country`       | Country                 |                   | `view`
`customerID`    | Customer&nbsp;ID        |                   | `view`
`postcode`      | Postcode                |                   | `view`
`referenceName` | Customer reference name |                   | `view`

## Call Recording

This object provides details of recent call recordings.

### URL

`/CallRecording`

### Fields

Name            | Description                | Required&nbsp;for | Returned&nbsp;by
--------------- | -------------------------- | ----------------- | ----------------
`CLI`           | Telephone number presented |                   | `view`
`customerID`    | Customer&nbsp;ID           |                   | `view`
`DNI`           | Telephone number dialled   |                   | `view`
`duration`      | Duration, in seconds       |                   | `view`
`endTime`       | Call end time              |                   | `view`
`objectID`      | Object&nbsp;ID             | `download`        | `view`
`referenceName` | Customer reference name    |                   | `view`

## Call Summary

This object provides a summary of recent call charges.

### URL

`/CallSummary`

### Fields

Name            | Description              | Required&nbsp;for | Returned&nbsp;by
--------------- | ------------------------ | ----------------- | ----------------
`answeredCalls` | Number of answered calls |                   | `view`
`cost`          | Call cost&nbsp;(£)       |                   | `view`
`customerID`    | Customer&nbsp;ID         |                   | `view`
`date`          | Date                     |                   | `view`
`description`   | Description              |                   | `view`
`direction`     | Call direction           |                   | `view`
`minutes`       | Call minutes             |                   | `view`
`prefix`        | Rate prefix              |                   | `view`
`referenceName` | Customer reference name  |                   | `view`
`timeband`      | Time band                |                   | `view`

### Additional view information

For `view` requests, the following additional information is returned inside `result`:

Name                 | Description                    | [Data&nbsp;type](#data-types-and-validation)
-------------------- | ------------------------------ | --------------------------------------------
`totalAnsweredCalls` | Total number of answered calls | `integer`
`totalCost`          | Total call cost&nbsp;(£)       | `decimal`
`totalMinutes`       | Total call minutes             | `decimal`
`totalVAT`           | Total VAT&nbsp;(£)             | `decimal`

<aside class='notice'>If any filters are included in the request then the above totals will correspond to the filtered results only.</aside>

## CDR

This object provides recent CDRs for all chargeable calls.

### URL

`/CDR`

### Fields

Name         | Description                         | Required&nbsp;for | Returned&nbsp;by
------------ | ----------------------------------- | ----------------- | ----------------
`answerTime` | Call answer time                    |                   | `view`
`CLIin`      | Telephone number presented&nbsp;in  |                   | `view`
`CLIout`     | Telephone number presented&nbsp;out |                   | `view`
`cost`       | Call cost&nbsp;(£)                  |                   | `view`
`customerID` | Customer&nbsp;ID                    | `view`            | 
`direction`  | Call direction                      |                   | `view`
`DNIin`      | Telephone number dialled&nbsp;in    |                   | `view`
`DNIout`     | Telephone number dialled&nbsp;out   |                   | `view`
`duration`   | Call duration, in seconds           |                   | `view`
`endTime`    | Call end time                       |                   | `view`
`prefix`     | Rate prefix                         |                   | `view`
`source`     | Call source                         |                   | `view`
`timeband`   | Time band                           |                   | `view`

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description       | Returned&nbsp;by
------------- | ----------------- | ----------------
433           | Request timed out | `view`

## Contact

This object handles customer contact details.

### URL

`/Contact`

### Fields

Name                 | Description                 | Required&nbsp;for      | Returned&nbsp;by
-------------------- | --------------------------- | ---------------------- | ----------------
`customerID`         | Customer&nbsp;ID            | `add`,&nbsp;`edit`     | `view`
`emailAddress`       | Contact email address       | `add`,&nbsp;`edit`     | `view`
`forename`           | Contact forename            | `add`,&nbsp;`edit`     | `view`
`objectID`           | Object&nbsp;ID              | `edit`,&nbsp;`remove`  | `add`,&nbsp;`view`
`referenceName`      | Customer reference name     |                        | `view`
`surname`            | Contact surname             | `add`,&nbsp;`edit`     | `view`
`telephoneExtension` | Contact telephone extension | `add`,&nbsp;`edit`     | `view`
`telephoneNumber`    | Contact telephone number    | `add`,&nbsp;`edit`     | `view`
`type`               | Contact type                | `add`,&nbsp;`edit`     | `view`

### Notes

When making an `add` or `edit` request:

* The `telephoneExtension` field is always nullable and can only be set when the `telephoneNumber` field is populated;
* Some other required fields are also nullable depending on the value of the `type` field, as specified in the table below, however the `forename` field must be set if the `surname` field is populated, and vice versa.

Contact&nbsp;type | Nullable&nbsp;fields
----------------- | --------------------
Accounts          | None
Alerts            | `forename`, `surname`, `telephoneNumber`
Complaints        | `forename`, `surname`, `telephoneNumber`
General           | `emailAddress` or `telephoneNumber` (but not both)
Nuisance          | `forename`, `surname`, `telephoneNumber`
Primary           | None
Rates             | `forename`, `surname`, `telephoneNumber`
Reports           | `forename`, `surname`, `telephoneNumber`
Routing           | `forename`, `surname`, `telephoneNumber`
Technical         | None

### Additional dynamic information

The following additional information is provided [dynamically](#requests):

Name                 | Description                                           | [Data&nbsp;type](#data-types-and-validation) | Array
-------------------- | ------------------------------------------------------| -------------------------------------------- | -----
`barredNumberRanges` | List of telephone number ranges barred on our network | `phoneRange`                                 | Yes

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description                                                               | Returned&nbsp;by
------------- | ------------------------------------------------------------------------- | ----------------
407           | Contact already exists                                                    | `add`,&nbsp;`edit`
408           | Customer should have at least one primary, accounts and technical contact | `edit`,&nbsp;`remove`
409           | Customer has reports distributed via email                                | `edit`,&nbsp;`remove`
418           | No changes effected                                                       | `edit`,&nbsp;`remove`
432           | Telephone number range invalid                                            | `add`,&nbsp;`edit`

## Dial Sure Summary

This object provides a summary of recent Dial Sure PPC charges.

### URL

`/DialSureSummary`

### Fields

Name            | Description             | Required&nbsp;for | Returned&nbsp;by
--------------- | ----------------------- | ----------------- | ----------------
`calls`         | Number of calls         |                   | `view`
`cost`          | Dial Sure cost&nbsp;(£) |                   | `view`
`customerID`    | Customer&nbsp;ID        |                   | `view`
`date`          | Date                    |                   | `view`
`PPCrate`       | Dial Sure PPC rate      |                   | `view`
`referenceName` | Customer reference name |                   | `view`

### Additional view information

For `view` requests, the following additional information is returned inside `result`:

Name         | Description                   | [Data&nbsp;type](#data-types-and-validation)
------------ | ----------------------------- | --------------------------------------------
`totalCalls` | Total number of calls         | `integer`
`totalCost`  | Total Dial Sure cost&nbsp;(£) | `decimal`
`totalVAT`   | Total VAT&nbsp;(£)            | `decimal`

<aside class='notice'>If any filters are included in the request then the above totals will correspond to the filtered results only.</aside>

## Invoice

This object provides information regarding customer invoices.

### URL

`/Invoice`

### Fields

Name               | Description                 | Required&nbsp;for | Returned&nbsp;by
------------------ | --------------------------- | ----------------- | ----------------
`customerID`       | Customer&nbsp;ID            |                   | `view`
`date`             | Date                        |                   | `view`
`grossAmount`      | Gross amount&nbsp;(£)       |                   | `view`
`invoiceNumber`    | Invoice number              | `download`        | `view`
`netAmount`        | Net amount&nbsp;(£)         |                   | `view`
`referenceName`    | Customer reference name     |                   | `view`
`type`             | Invoice type                |                   | `view`
`VAT`              | VAT&nbsp;(£)                |                   | `view`
`VATreverseCharge` | VAT reverse charge&nbsp;(£) |                   | `view`

## Outbound Rates

This object provides information regarding customer outbound rates.

### URL

`/OutboundRates`

### Fields

Name                 | Description      | Required&nbsp;for | Returned&nbsp;by
-------------------- | ---------------- | ----------------- | ----------------
`customerID`         | Customer&nbsp;ID | `view`            | 
`description`        | Rate description |                   | `view`
`month`              | Month            | `view`            |
`PPCday`             | PPC daytime      |                   | `view`
`PPCeve`             | PPC evening      |                   | `view`
`PPCwkd`             | PPC weekend      |                   | `view`
`PPMday`             | PPM daytime      |                   | `view`
`PPMeve`             | PPM evening      |                   | `view`
`PPMwkd`             | PPM weekend      |                   | `view`
`prefix`             | Rate prefix      |                   | `view`
`zeroPPMfirstMinute` | See notes        |                   | `view`

### Notes

The `zeroPPMfirstMinute` field specifies whether the PPM charge is applied during the first minute of the call.

### Additional dynamic information

The following additional information is provided [dynamically](#requests):

Name               | Description                                                        | [Data&nbsp;type](#data-types-and-validation) | Array
------------------ | ------------------------------------------------------------------ | -------------------------------------------- | -----
`rateCardIssueDay` | Day of the month the following month's rate card is made available | `integer`                                    | No
`specialNumbers`   | List of special UK telephone numbers allowed on our network        | `text`                                       | Yes

### Additional view information

For `view` requests, the following additional information is returned inside `result`:

Name          | Description        | [Data&nbsp;type](#data-types-and-validation)
------------- | ------------------ | --------------------------------------------
`DialSurePPC` | Dial Sure PPC rate | `decimal`

## Password

This object handles user passwords for this API.

### URL

`/Password`

### Fields

Name         | Description          | Required&nbsp;for | Returned&nbsp;by
------------ | -------------------- | ----------------- | ----------------
`expiryDate` | Password expiry date |                   | `reset`
`password`   | User password        | `edit`            | `reset`
`username`   | Username             | `reset`           |

### Notes

Users can only edit their own password. Resetting another user's password returns a temporary password that can then be used to set that user's password (e.g. via a link in a verification email sent to them), and until this is done all other requests from that user will fail.

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description         | Returned&nbsp;by
------------- | ------------------- | ----------------
418           | No changes effected | `edit` 

## Report Distribution

This object handles the distribution of automated reports offered by Nexbridge.

### URL

`/ReportDistribution`

### Fields

Name            | Description             | Required&nbsp;for     | Returned&nbsp;by
--------------- | ----------------------- | --------------------- | ----------------
`bespoke`       | See notes               |                       | `view`
`customerID`    | Customer&nbsp;ID        | `add`,&nbsp;`edit`    | `view`
`frequency`     | Distribution frequency  | `add`,&nbsp;`edit`    | `view`
`method`        | Distribution method     | `add`,&nbsp;`edit`    | `view`
`objectID`      | Object&nbsp;ID          | `edit`,&nbsp;`remove` | `add`,&nbsp;`view`
`referenceName` | Customer reference name |                       | `view`
`type`          | Report type             | `add`,&nbsp;`edit`    | `view`

### Notes

The `bespoke` field specifies whether the report is bespoke or standard.

The `edit` and `remove` actions are only available for standard reports.

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description              | Returned&nbsp;by
------------- | ------------------------ | ----------------
411           | Report already exists    | `add`,&nbsp;`edit`
412           | Reports contact required | `add`,&nbsp;`edit`
413           | SFTP details required    | `add`,&nbsp;`edit`
418           | No changes effected      | `edit`,&nbsp;`remove`

## Route

This object handles telephony routes.

### URL

`/Route`

### Fields

Name                   | Description                                         | Required&nbsp;for     | Returned&nbsp;by
---------------------- | --------------------------------------------------- | --------------------- | ----------------
`application`          | Routing application                                 |                       | `view`
`applicationArguments` | Routing application arguments                       |                       | `view`
`compliant`            | [Compliance confirmation](#compliance-confirmation) | `edit`                |
`customerID`           | Customer&nbsp;ID                                    | `add`,&nbsp;`edit`    | `view`
`objectID`             | Object&nbsp;ID                                      | `edit`,&nbsp;`remove` | `add`,&nbsp;`edit`,&nbsp;`view`
`referenceName`        | Customer reference name                             |                       | `view`
`service`              | Routing service                                     | `add`,&nbsp;`edit`    |
`serviceArguments`     | Routing service arguments                           | `add`,&nbsp;`edit`    |

### Notes

Routing applications are split into **features** and **services**. Each route is comprised of one service and zero or more features applied to that service. Details of which features/services are available for inbound/outbound routes are provided dynamically. The argument(s) required for each service are specified in the table below; where none are required, the `serviceArguments` field must still be present in the request with its value set to an empty string.

When making an `edit` request, an inbound service cannot be changed to an outbound service, and vice versa.

The `compliant` field is only required for an `edit` request when removing the `enableTPS` feature from a route.

Routing&nbsp;service | Number&nbsp;of&nbsp;arguments | Argument&nbsp;[data&nbsp;type](#data-types-and-validation)
-------------------- | ----------------------------- | ----------------------------------------------------------
`simpleTranslation`  | 1                             | `host` or `routablePhone`
`teleswitch`         | 0                             |

### Additional dynamic information

The following additional information is provided [dynamically](#requests):

Name                 | Description                                                                       | [Data&nbsp;type](#data-types-and-validation) | Array
-------------------- | --------------------------------------------------------------------------------- | -------------------------------------------- | -----
`availableFeatures`  | List of available routing features, subdivided into `inbound` and `outbound`      | `text`                                       | Yes
`availableServices`  | List of available routing services, subdivided into `inbound` and `outbound`      | `text`                                       | Yes
`barredNumberRanges` | List of telephone number ranges barred on our network                             | `phoneRange`                                 | Yes
`reservedCIDRranges` | List of reserved IP address ranges that are not allowed as an inbound destination | `CIDR`                                       | Yes

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description                                          | Returned&nbsp;by
------------- | ---------------------------------------------------- | ----------------
418           | No changes effected                                  | `edit`,&nbsp;`remove`
424           | Route still in use                                   | `remove`
426           | Cannot route to telephone number hosted by Nexbridge | `add`,&nbsp;`edit`
428           | TPS screening only allowed for UK CLIs               | `edit`
432           | Telephone number range invalid                       | `add`,&nbsp;`edit`

## Routing CLI

This object handles CLI-based outbound routing.

### URL

`/RoutingCLI`

### Fields

Name            | Description                                         | Required&nbsp;for     | Returned&nbsp;by
--------------- | --------------------------------------------------- | --------------------- | ----------------
`compliant`     | [Compliance confirmation](#compliance-confirmation) | `add`,&nbsp;`edit`    |
`customerID`    | Customer&nbsp;ID                                    | `add`,&nbsp;`edit`    | `view`
`objectID`      | Object&nbsp;ID                                      | `edit`,&nbsp;`remove` | `add`,&nbsp;`view`
`referenceName` | Customer reference name                             |                       | `view`
`routeID`       | See notes                                           | `add`,&nbsp;`edit`    | `view`
`routingCLI`    | Outbound routing&nbsp;CLI                           | `add`,&nbsp;`edit`    | `view`

### Notes

The `routeID` field links the outbound routing CLI with its corresponding [route](#route).

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description                           | Returned&nbsp;by
------------- | ------------------------------------- | ----------------
418           | No changes effected                   | `add`,&nbsp;`edit`,&nbsp;`remove`
419           | Telephone number in use               | `add`,&nbsp;`edit`
422           | Valid inbound route required          | `add`,&nbsp;`edit`
427           | Telephone number has been blacklisted | `add`,&nbsp;`edit`
432           | Telephone number range invalid        | `add`,&nbsp;`edit`

## Routing DNI

This object handles the call routing for telephone numbers hosted on our network.

### URL

`/RoutingDNI`

### Fields

Name            | Description                   | Required&nbsp;for  | Returned&nbsp;by
--------------- | ----------------------------- | ------------------ | ----------------
`customerID`    | Customer&nbsp;ID              | `add`              | `view`
`numberRange`   | Telephone number range        | `add`              |
`quantity`      | Quantity of telephone numbers | `add`              |
`referenceName` | Customer reference name       |                    | `view`
`routeID`       | See notes                     | `add`,&nbsp;`edit` | `view`
`routingDNI`    | Hosted telephone number       | `edit`             | `add`,&nbsp;`view`

### Notes

The `routeID` field links the hosted telephone number with its corresponding [route](#route).

### Additional dynamic information

As well as the usual list of available values, the `enumerate` action for the `numberRange` field also returns the short code for each telephone number range as the corresponding array key.

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description                                              | Returned&nbsp;by
------------- | -------------------------------------------------------- | ----------------
418           | No changes effected                                      | `add`,&nbsp;`edit`
419           | Telephone number in use                                  | `edit`
422           | Valid inbound route required                             | `add`,&nbsp;`edit`
434           | Allocation limit reached for this telephone number range | `add`

## SFTP Details

This object handles the SFTP details used for automated uploads.

### URL

`/SFTPdetails`

### Fields

Name            | Description             | Required&nbsp;for      | Returned&nbsp;by
--------------- | ----------------------- | ---------------------- | ----------------
`customerID`    | Customer&nbsp;ID        | `add`,&nbsp;`edit`     | `view`
`directory`     | SFTP directory          | `add`,&nbsp;`edit`     | `view`
`host`          | SFTP host               | `add`,&nbsp;`edit`     | `view`
`objectID`      | Object&nbsp;ID          | `edit`,&nbsp;`remove`  | `add`,&nbsp;`view`
`password`      | SFTP password           | `add`,&nbsp;`edit`     | `view`
`port`          | SFTP port               | `add`,&nbsp;`edit`     | `view`
`referenceName` | Customer reference name |                        | `view`
`type`          | Data type               | `add`,&nbsp;`edit`     | `view`
`username`      | SFTP username           | `add`,&nbsp;`edit`     | `view`

### Notes

When making an `add` or `edit` request, the `directory` field is nullable.

### Additional dynamic information

The following additional information is provided [dynamically](#requests):

Name                       | Description                                                               | [Data&nbsp;type](#data-types-and-validation) | Array
-------------------------- | ------------------------------------------------------------------------- | -------------------------------------------- | -----
`NexbridgeCIDRranges`      | List of IP address ranges to be allowed through the SFTP host firewall    | `CIDR`                                       | Yes
`rateCardIssueDay`         | Day of the month the following month's rate card is made available        | `integer`                                    | No
`recordingUploadFrequency` | How often call recordings are uploaded via SFTP, in minutes               | `integer`                                    | No
`reservedCIDRranges`       | List of reserved IP address ranges that are not allowed for the SFTP host | `CIDR`                                       | Yes

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description                                               | Returned&nbsp;by
------------- | --------------------------------------------------------- | ----------------
410           | Customer has reports distributed via SFTP                 | `edit`,&nbsp;`remove`
414           | SFTP details of this type already exist for this customer | `add`,&nbsp;`edit`
418           | No changes effected                                       | `edit`,&nbsp;`remove`

## Source IP

This object handles the source IP addresses used to send outbound calls to our network.

### URL

`/SourceIP`

### Fields

Name            | Description             | Required&nbsp;for     | Returned&nbsp;by
--------------- | ----------------------- | --------------------- | ----------------
`customerID`    | Customer&nbsp;ID        | `add`,&nbsp;`edit`    | `view`
`objectID`      | Object&nbsp;ID          | `edit`,&nbsp;`remove` | `add`,&nbsp;`view`
`referenceName` | Customer reference name |                       | `view`
`sourceIP`      | Source IP address       | `add`,&nbsp;`edit`    | `view`

### Additional dynamic information

The following additional information is provided [dynamically](#requests):

Name                 | Description                                                                    | [Data&nbsp;type](#data-types-and-validation) | Array
-------------------- | ------------------------------------------------------------------------------ | -------------------------------------------- | -----
`reservedCIDRranges` | List of reserved IP address ranges that are not allowed as a source IP address | `CIDR`                                       | Yes

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description         | Returned&nbsp;by
------------- | ------------------- | ----------------
418           | No changes effected | `edit`,&nbsp;`remove`
430           | IP address in use   | `add`,&nbsp;`edit`

## User

This object handles the users able to access this API.

### URL

`/User`

### Fields

Name            | Description             | Required&nbsp;for      | Returned&nbsp;by
--------------- | ----------------------- | ---------------------- | ----------------
`active`        | See notes               | `edit`                 | `view`
`customerID`    | Customer&nbsp;ID        | `add`,&nbsp;`edit`     | `view`
`expiryDate`    | Password expiry date    |                        | `add`,&nbsp;`edit`
`objectID`      | Object&nbsp;ID          | `edit`,&nbsp;`remove`  | `add`,&nbsp;`view`
`password`      | User password           |                        | `add`,&nbsp;`edit`
`passwordSet`   | See notes               |                        | `view`
`referenceName` | Customer reference name |                        | `view`
`role`          | User role               | `add`,&nbsp;`edit`     | `view`
`username`      | Username                | `add`,&nbsp;`edit`     | `view`

### Notes

The `active` field specifies whether the user is currently allowed to access the API.

The `passwordSet` field specifies whether the user has set their password.

The following restrictions apply:

* You cannot de-activate your own user;
* You cannot change the customer ID of your own user;
* You cannot change the role of your own user;
* You cannot remove your own user.

When making an `add` request, or an `edit` request that changes the username, a temporary password will be returned, which can then be used to set that user's password (e.g. via a link in a verification email sent to them), and until this is done all other requests from that user will fail.

### Additional dynamic information

The following additional information is provided [dynamically](#requests):

Name              | Description                               | [Data&nbsp;type](#data-types-and-validation) | Array
----------------- | ----------------------------------------- | -------------------------------------------- | -----
`accessibleRoles` | List of user roles accessible to the user | `text`                                       | Yes

### API codes

The following [API codes](#responses) can be returned by this object:

API&nbsp;code | Description         | Returned&nbsp;by
------------- | ------------------- | ----------------
406           | User already exists | `add`,&nbsp;`edit`
417           | Role not available  | `add`,&nbsp;`edit`
418           | No changes effected | `edit`,&nbsp;`remove`

&nbsp;
