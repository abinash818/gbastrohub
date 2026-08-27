const fs = require('fs');
const path = require('path');

const scriptToInject = `
<div class="zoom-controls">
  <button onclick="zoomIn()" title="Zoom In">+</button>
  <button onclick="zoomOut()" title="Zoom Out">-</button>
  <button onclick="window.print()" title="Print/Save PDF">🖨</button>
</div>
<style>
  .zoom-controls { position: fixed; bottom: 20px; right: 20px; display: flex; flex-direction: column; gap: 10px; z-index: 1000; }
  .zoom-controls button { width: 45px; height: 45px; border-radius: 50%; border: none; background: #5D1204; color: white; font-size: 24px; cursor: pointer; box-shadow: 0 4px 6px rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: center; }
  .zoom-controls button:hover { background: #B58D3D; }
  @media print { .zoom-controls { display: none !important; } }
</style>
<script>
  let currentZoom = 1.0;
  function zoomIn() {
    currentZoom += 0.1;
    document.body.style.zoom = currentZoom;
  }
  function zoomOut() {
    currentZoom -= 0.1;
    if(currentZoom < 0.3) currentZoom = 0.3;
    document.body.style.zoom = currentZoom;
  }
</script>
`;

const dir = 'lib/services';
const files = fs.readdirSync(dir)
  .filter(f => f.endsWith('pdf_service.dart'))
  .map(f => path.join(dir, f));

files.forEach(file => {
  let content = fs.readFileSync(file, 'utf8');
  if (content.includes('</body>') && !content.includes('zoom-controls')) {
    content = content.replace('</body>', scriptToInject + '\n</body>');
    fs.writeFileSync(file, content, 'utf8');
    console.log('Injected zoom controls into', file);
  } else {
    console.log('Already injected or no </body> found in', file);
  }
});
