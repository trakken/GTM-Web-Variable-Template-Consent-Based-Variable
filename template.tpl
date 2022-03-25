___INFO___



{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Consent-based Variable",
  "description": "Anonymise fields based on the user\u0027s consent for analytics_storage by setting them as undefined, hashing or replacing them.",
  "containerContexts": [
    "WEB"
  ]
}



___NOTES___



Created on 23/03/2022, 17:24:51

___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// getting variables & consent
const isConsentGranted = require("isConsentGranted");
const log = require("logToConsole");

log(data);

if (isConsentGranted("analytics_storage")) {
  log("consent is granted. returning original");
  return data.inputVariable;
}

log("consent is not granted.");
if (data.anonymizationType === "hash") {
  return getCyrb53Hash(data.inputVariable + data.anonymizationSalt, 0);
}

if (data.anonymizationType === "custom") {
  return data.anonymizationCustom;
}

return undefined;

// ---- functions
function charCodeAt(str) {
  const asciiString =
    " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
  const asciiOffset = 32;
  return asciiString.indexOf(str) + asciiOffset;
}

function imul(a, b) {
  var aHi = (a >>> 16) & 65535;
  var aLo = a & 65535;
  var bHi = (b >>> 16) & 65535;
  var bLo = b & 65535;
  return (aLo * bLo + (((aHi * bLo + aLo * bHi) << 16) >>> 0)) | 0;
}

function getCyrb53Hash(str, seed) {
  seed = seed || 0;
  let h1 = 3735928559 ^ seed,
    h2 = 1103547991 ^ seed;
  for (let i = 0, ch; i < str.length; i++) {
    ch = charCodeAt(str[i]);
    h1 = imul(h1 ^ ch, 2654435761);
    h2 = imul(h2 ^ ch, 1597334677);
  }
  h1 = imul(h1 ^ (h1 >>> 16), 2246822507) ^ imul(h2 ^ (h2 >>> 13), 3266489909);
  h2 = imul(h2 ^ (h2 >>> 16), 2246822507) ^ imul(h1 ^ (h1 >>> 13), 3266489909);
  return 4294967296 * (2097151 & h2) + (h1 >>> 0).toString(16);
}

___TEMPLATE_PARAMETERS___

[
  {
    "type": "LABEL",
    "name": "label1",
    "displayName": "If anyltics_storage consent is granted, this variable returns the original input variable. If not, it returns the anonmyized input variable."
  },
  {
    "type": "LABEL",
    "name": "label2",
    "displayName": "▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️",
    "enablingConditions": []
  },
  {
    "type": "SELECT",
    "name": "inputVariable",
    "displayName": "Select the input variable",
    "macrosInSelect": true,
    "selectItems": [],
    "simpleValueType": true
  },
  {
    "type": "LABEL",
    "name": "label3",
    "displayName": "▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️ ▪️",
    "enablingConditions": []
  },
  {
    "type": "RADIO",
    "name": "anonymizationType",
    "displayName": "Anonymisation type if analytics_storage is denied",
    "radioItems": [
      {
        "value": "undef",
        "displayValue": "return undefined",
        "help": "recommended for user_id and other static user identifiers"
      },
      {
        "value": "hash",
        "displayValue": "return hashed input value",
        "help": "recommended for transaction_id"
      },
      {
        "value": "custom",
        "displayValue": "return a custom value",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      }
    ],
    "simpleValueType": true,
    "valueValidators": []
  },
  {
    "type": "TEXT",
    "name": "anonymizationCustom",
    "hint": "Enter a custom value",
    "displayName": "Select the variable or enter a static string you want to return",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "anonymizationType",
        "paramValue": "custom",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "anonymizationSalt",
    "displayName": "Add salt to hashing (optional)",
    "hint": "random piece of text",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "anonymizationType",
        "paramValue": "hash",
        "type": "EQUALS"
      }
    ]
  }
]

___TERMS_OF_SERVICE___



By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.



___TESTS___



scenarios:
- name: returns original is consent granted
  code: |-
    const mockData = {
      inputVariable: "unique-user-id"
    };

    mock("isConsentGranted", function() {
      return true;
    });


    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
    assertThat(variableResult).isEqualTo(mockData.inputVariable);
- name: returns undefined
  code: |-
    const mockData = {
      inputVariable: "unique-user-id",
      anonymizationType: "undef"
    };

    mock("isConsentGranted", function() {
      return false;
    });


    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(undefined);
- name: returns hash
  code: |-
    const mockData = {
      inputVariable: "unique-user-id",
      anonymizationType: "hash"
    };

    mock("isConsentGranted", function() {
      return false;
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
    assertThat(variableResult).isNotEqualTo(data.inputVariable);
- name: salted hash is different from unsalted hash
  code: |
    const mockData = {
      inputVariable: "unique-user-id",
      anonymizationType: "hash",
    };

    mock("isConsentGranted", function() {
      return false;
    });

    // Call runCode to run the template's code.
    let variableResultWithoutSalt = runCode(mockData);

    mockData.anonymizationSalt = "saltz";
    let variableResultWithSalt = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResultWithoutSalt).isNotEqualTo(variableResultWithSalt);
- name: returns custom
  code: |-
    const mockData = {
      inputVariable: "unique-user-id",
      anonymizationType: "custom",
      anonymizationCustom: "customValue"
    };

    mock("isConsentGranted", function() {
      return false;
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(mockData.anonymizationCustom);

___WEB_PERMISSIONS___



[
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "analytics_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]


