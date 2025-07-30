<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>EICR Official Compliant App</title>
  <link rel="manifest" href="manifest.json">
  <meta name="theme-color" content="#000000">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  <script>
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('sw.js');
    }
  </script>
  <style>
    body { font-family: Arial, sans-serif; padding: 10px; background: #f8f8f8; }
    h1 { text-align: center; margin-bottom: 10px; }
    .section { background: #fff; padding: 15px; margin-bottom: 10px; border-radius: 6px; }
    label { display: block; margin-top: 8px; font-weight: bold; }
    input, textarea, select { width: 100%; margin: 5px 0; padding: 6px; }
    button { margin-top: 10px; background: #2563eb; color: #fff; border: none; padding: 10px; border-radius: 5px; cursor: pointer; }
    .mic { background: #10b981; margin-left: 5px; }
    canvas { border: 1px solid #ccc; margin-top: 10px; }
  </style>
</head>
<body>
  <h1>Electrical Installation Condition Report</h1>

  <div class="section">
    <h2>Client & Job Details</h2>
    <label>Client Name</label><div><input id="clientName"><button class="mic" onclick="startVoice('clientName')">🎤</button></div>
    <label>Address</label><div><textarea id="clientAddress"></textarea><button class="mic" onclick="startVoice('clientAddress')">🎤</button></div>
    <label>Purpose</label><div><input id="purpose"><button class="mic" onclick="startVoice('purpose')">🎤</button></div>
    <label>Date</label><input id="inspectionDate" type="date">
    <label>Installation Details</label><div><textarea id="installationDetails"></textarea><button class="mic" onclick="startVoice('installationDetails')">🎤</button></div>
  </div>
  <div class="section">
    <h2>Supply Characteristics</h2>
    <label>Earthing Arrangement</label><div><input id="earthing"><button class="mic" onclick="startVoice('earthing')">🎤</button></div>
    <label>Main Protective Device</label><div><input id="device"><button class="mic" onclick="startVoice('device')">🎤</button></div>
    <label>Ze (Ω)</label><div><input id="ze"><button class="mic" onclick="startVoice('ze')">🎤</button></div>
    <label>Nominal Voltage (V)</label><div><input id="voltage"><button class="mic" onclick="startVoice('voltage')">🎤</button></div>
    <label>Frequency (Hz)</label><div><input id="frequency"><button class="mic" onclick="startVoice('frequency')">🎤</button></div>
  </div>

  <div class="section">
    <h2>Extent & Limitations</h2>
    <div><textarea id="limitations"></textarea><button class="mic" onclick="startVoice('limitations')">🎤</button></div>
  </div>

  <div class="section">
    <h2>Schedule of Inspections</h2>
    <div id="inspectionChecklist"></div>
  </div>

  <div class="section">
    <h2>Observations</h2>
    <button onclick="addObservation()">+ Observation</button>
    <div id="observations"></div>
  </div>
  <div class="section">
    <h2>Schedule of Test Results</h2>
    <button onclick="addCircuit()">+ Circuit</button>
    <div id="circuits"></div>
  </div>

  <div class="section">
    <h2>Continuation (Additional Notes)</h2>
    <div><textarea id="additionalNotes"></textarea><button class="mic" onclick="startVoice('additionalNotes')">🎤</button></div>
  </div>

  <div class="section">
    <h2>Declaration & Signature</h2>
    <canvas id="sigCanvas" width="300" height="100"></canvas><br>
    <button onclick="clearSig()">Clear Signature</button>
  </div>

  <div class="section"><button onclick="downloadPDF()">Download PDF</button></div>
<script>
function startVoice(fieldId) {
  if (!('webkitSpeechRecognition' in window)) { alert("Voice not supported"); return; }
  const r = new webkitSpeechRecognition();
  r.lang = 'en-GB';
  r.onresult = e => document.getElementById(fieldId).value = e.results[0][0].transcript;
  r.start();
}

const inspectionItems = [
  "Presence of earthing conductor","Main protective bonding","Condition of intake equipment","Condition of service head",
  "Presence of diagrams","Presence of labels","Presence of notices","Condition of consumer unit",
  "Presence of RCD","Operation of RCD test button","Circuit identification correct","Presence of warning notices",
  "Condition of wiring","Correct polarity","Condition of connections","Presence of IP-rated enclosures"
];
const checklistDiv = document.getElementById('inspectionChecklist');
inspectionItems.forEach((item, i) => {
  const div = document.createElement('div');
  div.innerHTML = `<label>${i+1}. ${item} <select id="ins${i}"><option value="✔" selected>✔</option><option value="✘">✘</option><option value="LIM">LIM</option><option value="N/A">N/A</option></select> <button class="mic" onclick="startVoice('ins${i}')">🎤</button></label>`;
  checklistDiv.appendChild(div);
});

function addObservation(){
  const d=document.createElement('div'), id='obs_'+document.querySelectorAll('#observations input').length;
  d.innerHTML=`<input id="${id}" placeholder="Observation"><button class="mic" onclick="startVoice('${id}')">🎤</button>`;
  document.getElementById('observations').appendChild(d);
}
function addCircuit(){
  const idx=document.querySelectorAll('#circuits div').length;
  const id='cir_'+idx;
  const d=document.createElement('div');
  d.innerHTML=
    `<input id="${id}_ref" placeholder="Ref" style="width:10%"><button class="mic" onclick="startVoice('${id}_ref')">🎤</button>
     <input id="${id}_desc" placeholder="Description" style="width:25%"><button class="mic" onclick="startVoice('${id}_desc')">🎤</button>
     <input id="${id}_pd" placeholder="Device" style="width:20%"><button class="mic" onclick="startVoice('${id}_pd')">🎤</button>
     <input id="${id}_r1r2" placeholder="R1+R2 (Ω)" style="width:15%"><button class="mic" onclick="startVoice('${id}_r1r2')">🎤</button>
     <input id="${id}_zs" placeholder="Zs (Ω)" style="width:10%"><button class="mic" onclick="startVoice('${id}_zs')">🎤</button>
     <input id="${id}_ir" placeholder="IR (MΩ)" style="width:10%"><button class="mic" onclick="startVoice('${id}_ir')">🎤</button>`;
  document.getElementById('circuits').appendChild(d);
}

const canvas = document.getElementById('sigCanvas');
const ctx = canvas.getContext('2d'); let drawing=false;
canvas.addEventListener('mousedown', () => drawing=true);
canvas.addEventListener('mouseup', () => drawing=false);
canvas.addEventListener('mousemove', e => { if (!drawing) return; ctx.fillStyle='black'; ctx.beginPath(); ctx.arc(e.offsetX, e.offsetY,2,0,Math.PI*2); ctx.fill(); });
function clearSig(){ ctx.clearRect(0,0,canvas.width,canvas.height); }
</script>
<script>
async function downloadPDF(){
  const { jsPDF } = window.jspdf;
  const doc = new jsPDF('p','mm','a4');

  const bg1 = await loadImage('blank EICR document_page-0001.jpg');
  doc.addImage(bg1,'JPEG',0,0,210,297);
  const ph=await loadImage('powerhive-logo.png');
  const nap=await loadImage('napit-logo.png');
  doc.addImage(ph,'PNG',10,5,25,10);
  doc.addImage(nap,'PNG',170,5,25,10);

  doc.setFontSize(10);
  doc.text(document.getElementById('clientName').value,50,45);
  doc.text(document.getElementById('clientAddress').value,50,52);
  doc.text(document.getElementById('purpose').value,50,59);
  doc.text(document.getElementById('inspectionDate').value,160,59);
  doc.text(document.getElementById('installationDetails').value,50,67);
  doc.text(document.getElementById('earthing').value,50,84);
  doc.text(document.getElementById('device').value,50,89);
  doc.text(document.getElementById('ze').value,160,89);
  doc.text(document.getElementById('voltage').value,50,95);
  doc.text(document.getElementById('frequency').value,160,95);

  const bg2 = await loadImage('blank EICR document_page-0002.jpg');
  doc.addPage(); doc.addImage(bg2,'JPEG',0,0,210,297);
  let y=75; inspectionItems.forEach((_,i)=>{
    const v=document.getElementById(`ins${i}`).value;
    doc.text(v,190,y); y+=5;
  });

  for(let p=3;p<=6;p++){
    const bg=await loadImage(`blank EICR document_page-000${p}.jpg`);
    doc.addPage(); doc.addImage(bg,'JPEG',0,0,210,297);
  }

  const obsStart=85;
  let yy=obsStart;
  document.querySelectorAll('#observations input').forEach(i=>{
    doc.text(i.value,20,yy); yy+=5;
  });

  const tblStart=80;
  let stY=tblStart;
  document.querySelectorAll('#circuits div').forEach(div=>{
    const inp=div.querySelectorAll('input');
    doc.text(inp[0].value,20,stY);
    doc.text(inp[1].value,40,stY);
    doc.text(inp[2].value,90,stY);
    doc.text(inp[3].value,130,stY);
    doc.text(inp[4].value,150,stY);
    doc.text(inp[5].value,170,stY);
    stY+=6;
  });

  const bg7 = await loadImage('blank EICR document_page-0007.jpg');
  doc.addPage(); doc.addImage(bg7,'JPEG',0,0,210,297);
  const sig=canvas.toDataURL('image/png');
  doc.addImage(sig,'PNG',60,230,60,20);

  doc.save("EICR_Report.pdf");
}
function loadImage(u){return new Promise(r=>{const i=new Image(); i.src=u; i.onload=()=>r(i);});}
</script>
</body>
</html>
