import CodeMirror from "codemirror";

let config = {
      mode: "markdown",
      lineNumbers: true,
      theme: "material",
      spellcheck: true,
    }

let Hooks = {}
Hooks.Editor = {
  codemirror: null,

  sendUpdate(editor, changes) {
    this.pushEvent("editor-changes",
      {
        current_text: editor.getDoc().getValue(),
        changes: Array.of(changes),
        cursor: editor.getCursor()
    })
  },

  mounted() {
    this.codemirror = CodeMirror.fromTextArea(this.el, config)
    let cursor = JSON.parse(document.querySelector("#cursor").value)
    this.codemirror.getDoc().setValue(document.querySelector("#content").textContent)
    this.codemirror.setCursor(cursor.value.line, cursor.value.ch)
    this.codemirror.on("changes", this.sendUpdate.bind(this))

    this.codemirror.on("cursorActivity", (editor) => {
      this.pushEvent("cursor-activity", editor.cursorCoords())
    })
  },

  updated() {
    this.codemirror = CodeMirror.fromTextArea(this.el, config)
    let cursor = JSON.parse(document.querySelector("#cursor").value)
    this.codemirror.getDoc().setValue(document.querySelector("#content").textContent)
    this.codemirror.setCursor(cursor.value.line, cursor.value.ch)
    this.codemirror.focus()

    this.codemirror.on("changes", this.sendUpdate.bind(this))

    this.codemirror.on("cursorActivity", (editor) => {
      this.pushEvent("cursor-activity", editor.cursorCoords())
    })
  }
}

export default Hooks
