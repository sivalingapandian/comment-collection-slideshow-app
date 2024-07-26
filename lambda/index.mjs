import { DynamoDB } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocument } from '@aws-sdk/lib-dynamodb';
import { randomUUID } from 'crypto'


const dynamo = DynamoDBDocument.from(new DynamoDB());
const TABLE_NAME = 'Messages';
const ITEMS_PER_PAGE = 5;
const scanParams = {
    TableName: TABLE_NAME,
};


/**
 * Demonstrates a simple HTTP endpoint using API Gateway. You have full
 * access to the request and response payload, including headers and
 * status code.
 *
 * To scan a DynamoDB table, make a GET request with the TableName as a
 * query string parameter. To put, update, or delete an item, make a POST,
 * PUT, or DELETE request respectively, passing in the payload to the
 * DynamoDB API as a JSON body.
 */
export const handler = async (event) => {
    console.log('Received event:', JSON.stringify(event));

    //let buff = Buffer.from(event.body, "base64");
    //let eventBodyStr = buff.toString('UTF-8');
    //let eventBody = JSON.parse(eventBodyStr);
    let eventBody = JSON.parse(event.body);
    console.log('Event body:', eventBody);

    let body;
    let statusCode = '200';
    const headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT',
        'Access-Control-Allow-Origin': '*'
    };

    try {
        switch (event.httpMethod) {
            case 'OPTIONS':
                body = "";
                break;
            case 'GET':
                //body = await dynamo.scan({ TableName: event.queryStringParameters.TableName });
                let { index } = event.queryStringParameters || { index: '0' };
                index = parseInt(index);

                const data = await dynamo.scan(scanParams);
                const messages = data.Items;

                if (messages.length === 0) {
                    body = { messages: [], nextIndex: 0 };
                }
                else {
                    const paginatedMessages = messages.slice(index, index + ITEMS_PER_PAGE);
                    let nextIndex = (index + ITEMS_PER_PAGE) % messages.length;
                    if (nextIndex < ITEMS_PER_PAGE) {
                        nextIndex = 0;
                    }
                    body = { messages: paginatedMessages, nextIndex };
                }
                break;
            case 'POST':
                let name = eventBody.name;
                let text = eventBody.text;
                const uuid = randomUUID();
                const params = {
                    TableName: TABLE_NAME,
                    Item: {
                        id: uuid,
                        name: name,
                        text: text
                    }
                };
                console.log('DynamoDB entry:', JSON.stringify(params));
                body = await dynamo.put(params);
                break;
            default:
                throw new Error(`Unsupported method "${event.httpMethod}"`);
        }
    }
    catch (err) {
        statusCode = '400';
        body = err.message;
    }
    finally {
        body = JSON.stringify(body);
    }

    return {
        statusCode,
        body,
        headers,
    };
};
