const SPREADSHEET_ID = 'PASTE_SPREADSHEET_ID_HERE';
const RECIPIENT_SHEET = '응답';
const ADMIN_TOKEN = 'dabar0904';

function doPost(e) {
  const payload = JSON.parse(e.postData.contents || '{}');

  if (payload.action === 'signup') {
    return saveSignup_(payload);
  }

  if (payload.action === 'send' && payload.token === ADMIN_TOKEN) {
    return sendFile_(payload);
  }

  return json_({ok: false, error: 'unauthorized'});
}

function saveSignup_(payload) {
  if (!payload.name || !payload.email) {
    return json_({ok: false, error: 'invalid_request'});
  }

  const sheet = getSheet_();
  sheet.appendRow([new Date(), payload.name, payload.email]);
  return json_({ok: true});
}

function sendFile_(payload) {
  if (!payload.subject || !payload.message) {
    return json_({ok: false, error: 'invalid_request'});
  }

  const attachments = [];
  if (payload.fileName && payload.fileData) {
    attachments.push(Utilities.newBlob(
      Utilities.base64Decode(payload.fileData),
      payload.mimeType || 'application/octet-stream',
      payload.fileName
    ));
  }

  const rows = getSheet_().getDataRange().getValues();
  const recipients = [...new Set(rows.slice(1).map(row => String(row[2]).trim()).filter(Boolean))];

  recipients.forEach(email => MailApp.sendEmail({
    to: email,
    subject: payload.subject,
    body: payload.message,
    attachments: attachments
  }));

  return json_({ok: true, sent: recipients.length});
}

function getSheet_() {
  return SpreadsheetApp.openById(SPREADSHEET_ID).getSheetByName(RECIPIENT_SHEET);
}

function json_(value) {
  return ContentService.createTextOutput(JSON.stringify(value))
    .setMimeType(ContentService.MimeType.JSON);
}