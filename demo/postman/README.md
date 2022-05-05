# How to run postman tests locally
* Install newman cli tool. Execute [setup.sh](./setup.sh)
* Execute postman tests, by executing [perform_tests.sh](./perform_tests.sh). This script used an environment file pointing to the local environment. Replace or create a new environment file to point to your Azure environment.
```json
{
	"id": "d8bbf070-2b3b-4dfb-bd0f-0f670f55121c",
	"name": "checklist",
	"values": [
		{
			"key": "appUrl",
			"value": "YOUR ENVIRONMENT URL",
			"type": "default",
			"enabled": true
		}
	],
	"_postman_variable_scope": "environment",
	"_postman_exported_at": "2022-05-05T10:45:06.031Z",
	"_postman_exported_using": "Postman/9.16.1"
}
```

If you create a new environment file, please modify perform_tests.sh to point to the new environment file.
```bash
newman run check_lists_request.postman_collection.json -e YOUR_NEW_ENV_FILE.json
```