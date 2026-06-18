# V1 Migration

## Moving from Mantine's TipTap editor to Lexxy

Mantine TipTap editor format:

```html
<p>this is some text</p>
<p><strong>here is a bold</strong></p>
<ul>
  <li><p>this is a list item</p></li>
  <li><p>this is list item 2</p></li>
</ul>
<p>new paragraph</p>
<p><em>italics</em></p>
<p>
  <em><u>underline and italics</u></em>
</p>
<p></p>
<p>skipped a blank line</p>
<hr />
<p>^horizontal rule</p>
<ol>
  <li><p>ordered list</p></li>
  <li><p>another ordered list</p></li>
</ol>
<p>gonna end with an extra newline</p>
<p></p>
<p></p>
```

Lexxy editor format:

```html
<p>this is some text</p>
<p><strong>here is a bold</strong></p>
<ul>
  <li value="1">this is a list item</li>
  <li value="2">this is list item 2</li>
</ul>
<p>new paragraph</p>
<p><em>italics</em></p>
<p>
  <u><em>underline and italics</em></u>
</p>
<p><br /></p>
<p>skipped a blank line</p>
<hr />
<p>^horizontal rule</p>
<ol>
  <li value="1">ordered list</li>
  <li value="2">another ordered list</li>
</ol>
<p>gonna end with an extra newline</p>
<p><br /></p>
```
