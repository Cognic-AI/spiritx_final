import os
from dotenv import load_dotenv
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime

# Load environment variables
load_dotenv()

def send_email(receiver_name, receiver_email, items, item_name):
    """
    Sends a recommendation email for the requested sport item.

    :param receiver_name: Name of the recipient.
    :param receiver_email: Email address of the recipient.
    :param items: List containing the recommended item details.
    :param item_name: Name of the requested item.
    """
    # Get email credentials from environment variables
    sender_email = os.getenv("SMTP_SERVER_USERNAME")
    password = os.getenv("SMTP_SERVER_PASSWORD")

    # Create the email message
    message = MIMEMultipart("alternative")
    message["From"] = sender_email
    message["To"] = receiver_email
    message["Subject"] = f"Your Recommendations for {item_name}"

    # Build the HTML email content
    html_content = f"""
    <html>
    <body style="font-family: Arial, sans-serif; margin: 0; padding: 0;">
        <table style="width: 100%; border-collapse: collapse;">
            <tr>
                <td style="background-color: #4CAF50; color: white; text-align: center; padding: 20px;">
                    <h1 style="margin: 0;">Recommended Items for {item_name}</h1>
                </td>
            </tr>
            <tr>
                <td style="padding: 20px;">
                    <p style="font-size: 16px;">Dear <strong>{receiver_name}</strong>,</p>
                    <p style="font-size: 16px;">Thank you for your interest! Here are our recommendations for {item_name}:</p>
                    
                    <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
                        <tr style="background-color: #f8f8f8;">
                            <th style="padding: 10px; text-align: left; border-bottom: 2px solid #ddd;">Item Details</th>
                            <th style="padding: 10px; text-align: right; border-bottom: 2px solid #ddd;">Price</th>
                        </tr>
    """

    # Add each item to the email content
    for item in items:
        html_content += f"""
                        <tr>
                            <td style="padding: 15px; border-bottom: 1px solid #ddd;">
                                <div style="display: flex; align-items: center;">
                                    <img src="{item.image_link}" alt="{item.name}" style="width: 100px; height: auto; margin-right: 15px; border-radius: 5px;">
                                    <div>
                                        <h3 style="margin: 0; font-size: 16px;">{item.name}</h3>
                                        <p style="margin: 5px 0; color: #666;">Product Link: <a href="{item.link}" style="color: #4CAF50;">View Item</a></p>
                                    </div>
                                </div>
                            </td>
                            <td style="padding: 15px; text-align: right; border-bottom: 1px solid #ddd; font-weight: bold;">
                                {item.currency} {item.price}
                            </td>
                        </tr>
        """

    html_content += """
                    </table>
                    <p style="font-size: 14px; margin-top: 20px;">If you have any questions about these recommendations, please don't hesitate to contact us.</p>
                </td>
            </tr>
            <tr>
                <td style="background-color: #f1f1f1; text-align: center; padding: 10px; font-size: 12px;">
                    <p style="margin: 0;">&copy; 2024 Geniecart. All rights reserved.</p>
                </td>
            </tr>
        </table>
    </body>
    </html>
    """

    # Attach the HTML content to the email
    message.attach(MIMEText(html_content, "html"))

    try:
        # Connect to the SMTP server and send the email
        with smtplib.SMTP(os.getenv("SMTP_SERVER_HOST"), 587) as server:
            server.starttls()
            server.login(sender_email, password)
            server.sendmail(sender_email, receiver_email, message.as_string())
        return "Recommendation email sent successfully!"
    except smtplib.SMTPAuthenticationError:
        raise Exception("Failed to authenticate with SMTP server. Please check your email credentials in the .env file and ensure you're using an App Password if using Gmail.")
    except Exception as e:
        raise Exception(f"Failed to send email: {str(e)}")

# For testing - commented out to prevent accidental sends
# send_email("John Doe", "akinduhiman2@gmail.com", [], "Item Name")