{ CompositeDisposable } = require 'atom'

module.exports =
  config:
    visibility:
      type: 'string'
      default: 'showButtonsOnMarkdown'
      description: 'Configure toolbar visibility behaviour'
      enum: [
        'showToolbarOnMarkdown'
        'showButtonsOnMarkdown'
        'showButtonsOnAll'
      ]
    grammars:
      type: 'array'
      default: [
        'source.gfm'
        'source.gfm.nvatom'
        'source.litcoffee'
        'text.md'
        'text.plain'
        'text.plain.null-grammar'
      ]
      description: 'Valid file type grammars'

  buttons: [
    {
      'icon': 'file'
      'tooltip': 'Add New Post/Draft'
      'callback':
        '': 'markdown-writer:new-post'
        'shift': 'markdown-writer:new-draft'
    }
    {
      'icon': 'markdown'
      'tooltip': 'Preview Markdown'
      'data': ['markdown-preview', 'markdown-preview-plus']
      'visible': (data) ->
        pkg = data.find (pkg) -> !!atom.packages.getLoadedPackage(pkg)
        "#{pkg}:toggle" if pkg
    }
    { 'type': 'separator' }
    {
      'icon': 'tag'
      'tooltip': 'Manage Tags'
      'callback': 'markdown-writer:manage-post-tags'
    }
    {
      'icon': 'label'
      'tooltip': 'Manage Categories'
      'callback': 'markdown-writer:manage-post-categories'
    }
    { 'type': 'separator' }
    {
      'icon': 'link-variant'
      'tooltip': 'Insert Link'
      'callback':
        '': 'markdown-writer:insert-link'
        'shift': 'markdown-writer:open-link-in-browser'
    }
    {
      'icon': 'image'
      'tooltip': 'Insert Image'
      'callback': 'markdown-writer:insert-image'
    }
    { 'type': 'separator' }
    {
      'icon': 'format-bold'
      'tooltip': 'Bold'
      'callback': 'markdown-writer:toggle-bold-text'
    }
    {
      'icon': 'format-italic'
      'tooltip': 'Italic'
      'callback': 'markdown-writer:toggle-italic-text'
    }
    {
      'icon': 'code-tags'
      'tooltip': 'Code/Code Block'
      'callback':
        '': 'markdown-writer:toggle-code-text'
        'shift': 'markdown-writer:toggle-codeblock-text'
    }
    { 'type': 'separator' }
    {
      'icon': 'format-list-bulleted'
      'tooltip': 'Unordered List'
      'callback': 'markdown-writer:toggle-ul'
    }
    {
      'icon': 'format-list-numbers'
      'tooltip': 'Ordered List'
      'callback':
        '': 'markdown-writer:toggle-ol'
        'shift': 'markdown-writer:correct-order-list-numbers'
    }
    {
      'icon': 'playlist-check'
      'tooltip': 'Task List'
      'callback':
        '': 'markdown-writer:toggle-task'
        'shift': 'markdown-writer:toggle-taskdone'
    }
    { 'type': 'separator' }
    {
      'icon': 'format-header-1'
      'tooltip': 'Heading 1'
      'callback': 'markdown-writer:toggle-h1'
    }
    {
      'icon': 'format-header-2'
      'tooltip': 'Heading 2'
      'callback': 'markdown-writer:toggle-h2'
    }
    {
      'icon': 'format-header-3'
      'tooltip': 'Heading 3'
      'callback': 'markdown-writer:toggle-h3'
    }
    { 'type': 'separator' }
    {
      'icon': 'format-header-decrease'
      'tooltip': 'Jump to Previous Heading'
      'callback': 'markdown-writer:jump-to-previous-heading'
    }
    {
      'icon': 'format-header-increase'
      'tooltip': 'Jump to Next Heading'
      'callback': 'markdown-writer:jump-to-next-heading'
    }
    { 'type': 'separator' }
    {
      'icon': 'table'
      'tooltip': 'Insert Table'
      'callback': 'markdown-writer:insert-table'
    }
    {
      'icon': 'table-edit'
      'tooltip': 'Format Table'
      'callback': 'markdown-writer:format-table'
    }
  ]

  consumeToolBar: (toolBar) ->
    @toolBar = toolBar('tool-bar-markdown-writer')
    # cleaning up when tool bar is deactivated
    @toolBar.onDidDestroy => @toolBar = null
    # display buttons
    @addButtons()

  addButtons: ->
    return unless @toolBar?

    for button in @buttons
      if button['type'] == 'separator'
        @toolBar.addSpacer()
      else
        callback = button['callback']
        callback = button['visible'](button['data']) if button['visible']?
        continue unless callback

        @toolBar.addButton(
          icon: button['icon']
          data: button['data']
          callback: callback
          tooltip: button['tooltip']
          iconset: button['iconset'] || 'mdi')

  removeButtons: -> @toolBar?.removeItems()

  updateToolbarVisible: (visible) ->
    atom.config.set('tool-bar.visible', visible)

  isToolbarVisible: -> atom.config.get('tool-bar.visible')

  isMarkdown: ->
    editor = atom.workspace.getActiveTextEditor()
    return false unless editor?

    grammars = atom.config.get('tool-bar-markdown-writer.grammars')
    return grammars.indexOf(editor.getGrammar().scopeName) >= 0

  activate: ->
    require('atom-package-deps')
      .install('tool-bar-markdown-writer', true)
      .then(=> @activateBar())

  activateBar: ->
    @subscriptions = new CompositeDisposable()
    @subscriptions.add atom.workspace.onDidStopChangingActivePaneItem (item) =>
      visibility = atom.config.get('tool-bar-markdown-writer.visibility')

      if @isMarkdown()
        @removeButtons()
        @addButtons()
        @updateToolbarVisible(true) if visibility == 'showToolbarOnMarkdown'
      else if @isToolbarVisible()
        if visibility == 'showButtonsOnMarkdown'
          @removeButtons()
        else if visibility == 'showToolbarOnMarkdown'
          @updateToolbarVisible(false)

  deactivate: ->
    @subscriptions.dispose()
    @subscriptions = null
    @removeButtons()
