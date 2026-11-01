const RECIPIENT_SHEET = '응답';

function doPost(e) {
  const payload = JSON.parse(e.postData.contents || '{}');

  if (payload.action === 'signup') {
    return saveSignup_(payload);
  }

  if (payload.action === 'send') {
    const adminToken = PropertiesService.getScriptProperties().getProperty('ADMIN_TOKEN');
    if (adminToken && typeof payload.token === 'string' && payload.token === adminToken) {
      return sendFile_(payload);
    }
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
  const spreadsheetId = PropertiesService.getScriptProperties().getProperty('SPREADSHEET_ID');
  if (!spreadsheetId) {
    throw new Error('SPREADSHEET_ID script property is not configured');
  }
  return SpreadsheetApp.openById(spreadsheetId).getSheetByName(RECIPIENT_SHEET);
}

function json_(value) {
  return ContentService.createTextOutput(JSON.stringify(value))
    .setMimeType(ContentService.MimeType.JSON);
}
