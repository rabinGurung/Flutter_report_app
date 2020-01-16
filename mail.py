from flask import Flask, request, redirect, Response
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from flask_cors import CORS, cross_origin

app = Flask(__name__)
CORS(app)


@app.route("/mail", methods=['GET','POST'])
@cross_origin()
def mail():
    if request.method == "POST":
        if request.form:
            email = request.form['email']
            print(email)
            send_mail(email)
            return "Email Sent"
    return "Cannot send Mail"


@app.route("/")
def index():
    return "hello"


def send_mail(email):
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.ehlo()
    server.starttls()
    server.ehlo()
    server.login("leongurung029@gmail.com", "mmczspxeyjbefqro")

    subject = "New report is available"
    body = "Please open the system app to checkout the new report"

    msg = MIMEMultipart()
    msg['From'] = "leongurung029@gmail.com"
    msg['To'] = email
    msg['Subject'] = f"{subject}"
    msg.attach(MIMEText(body, 'plain'))
    server.send_message(msg)
    del msg
    print("mail send")
    server.quit()


if __name__ == '__main__':
    app.run(debug=True, host="192.168.0.101")
