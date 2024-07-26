# Create an S3 Bucket:

1. Go to the S3 console.
  * Click on "Create bucket".
  * Enter a unique bucket name and choose the region.
  * Leave other settings as default and create the bucket.
2. Upload index.html to the Bucket:
  * Update following in index.html
  ```javascript
  const apiURL = 'https://*.*.us-east-1.amazonaws.com/default/messageAPI';
  ```
  * Replace party.jpg with your image or replace the image in the folder
  * Click on the newly created bucket.
  * Click on "Upload" and select the index.html & image file.
3. Configure the Bucket for Static Website Hosting:
  * Go to the "Properties" tab.
  * Scroll down to "Static website hosting" and click "Edit".
  * Enable "Static website hosting".
  * Set the index document as index.html.
  * Save changes.
4. Set Permissions:
  * Go to the "Permissions" tab.
  * Click on "Bucket Policy".
  * Add the following policy to make the bucket publicly accessible:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
    }
  ]
}
```
  * Replace YOUR_BUCKET_NAME with your bucket's name.
  * Save changes.
5. Access Your Static Website:
  * Go back to the "Properties" tab.
  * Under "Static website hosting", you'll see the "Bucket website endpoint".
  * Click on it to access your newly created webpage.
