import sys

def main():
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Add the print button CSS
    css_insert = r'''
        .print-btn {
           position: fixed;
           top: 5mm;
           right: 5mm;
           background: var(--text-red);
           color: white;
           border: none;
           padding: 2mm 5mm;
           font-size: 3.5mm;
           font-weight: bold;
           border-radius: 1mm;
           cursor: pointer;
           z-index: 1000;
           box-shadow: 0 1mm 2mm rgba(0,0,0,0.3);
        }
        .print-btn:hover { background: #4A0E03; }
        @media print { .print-btn { display: none !important; } }
      </style>'''

    content = content.replace('</style>', css_insert)

    # Add the button in body
    body_insert = r'''<body>
      <button class="print-btn" onclick="window.print()">🖨️ Print / Save PDF</button>'''
      
    content = content.replace('<body>', body_insert)

    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Added Print button to Jamakkol PDF")

    # Now let's do the same for kp_one_page_pdf_service.dart
    try:
        with open('lib/services/kp_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
            kp_content = f.read()
            
        kp_content = kp_content.replace('</style>', css_insert)
        kp_content = kp_content.replace('<body>', body_insert)
        
        with open('lib/services/kp_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
            f.write(kp_content)
        print("Added Print button to KP PDF")
    except Exception as e:
        print("Could not update KP PDF:", e)
        
    # Let's also do it for one_page_pdf_service.dart
    try:
        with open('lib/services/one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
            basic_content = f.read()
            
        basic_content = basic_content.replace('</style>', css_insert)
        basic_content = basic_content.replace('<body>', body_insert)
        
        with open('lib/services/one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
            f.write(basic_content)
        print("Added Print button to Basic PDF")
    except Exception as e:
        print("Could not update Basic PDF:", e)

if __name__ == '__main__':
    main()
