import json
import urllib3
import os


def lambda_handler(event, context):
    private_ip = os.environ.get('PRIVATE_IP')
    """
    This function retrieves a path from the API Gateway path parameter
    and returns a simple JSON response.
    """
    print(f"Received event: {json.dumps(event)}")

    try:
        path = event['pathParameters']['path']

        response_message = f"Successfully retrieved data for path: {path}"

        # Construct the URL
        url = f"http://{private_ip}:5000/{path}"

        # Create an HTTP client
        http = urllib3.PoolManager()

        try:
            # Make the GET request
            response = http.request('GET', url)

            # Return the response data
            return {
                'statusCode': response.status,
                'body': response.data.decode('utf-8')
            }
        except Exception as e:
            # Handle exceptions
            return {
                'statusCode': 500,
                'body': str(e)
            }


    except KeyError:
        # Handle the case where 'userId' is not in the path parameters.
        return {
            'statusCode': 400,  # Bad Request
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': "The 'path' path parameter is missing."
            })
        }
    except Exception as e:
        # Handle other potential errors.
        print(f"Error: {e}")
        return {
            'statusCode': 500,  # Internal Server Error
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': "An internal server error occurred."
            })
        }

