{ CompositeDisposable } = require 'atom'

module.exports =
  config:
    visibility:
      type: 'string',
      default: 'showButtonsOnMarkdown',
      description: 'Configure toolbar visibility behaviour',
      enum: [
        'showToolbarOnMarkdown'
        'showButtonsOnMarkdown'
        'showButtonsOnAll'
      ]
    grammars:
      type: 'array',
      default: [
        'source.gfm'
        'source.gfm.nvatom'
        'source.litcoffee'
        'text.md'
        'text.plain'
        'text.plain.null-grammar'
      ],
      description: 'Valid file type grammars',

  buttons: [
    {
      'icon': 'file',
      'label': 'Add New Post',
      'command': 'markdown-writer:new-post'
    },
    {
      'icon': 'markdown',
      'label': 'Preview Markdown',
      'command': 'markdown-preview:toggle'
    },
    { 'type': 'separator' },
    {
      'icon': 'tag',
      'label': 'Manage Tags',
      'command': 'markdown-writer:manage-post-tags'
    },
    {
      'icon': 'label',
      'label': 'Manage Categories',
      'command': 'markdown-writer:manage-post-categories'
    },
    { 'type': 'separator' },
    {
      'icon': 'link-variant',
      'label': 'Insert Link',
      'command': 'markdown-writer:insert-link'
    },
    {
      'icon': 'image',
      'label': 'Insert Image',
      'command': 'markdown-writer:insert-image'
    },
    { 'type': 'separator' },
    {
      'icon': 'format-bold',
      'label': 'Bold',
      'command': 'markdown-writer:toggle-bold-text'
    },
    {
      'icon': 'format-italic',
      'label': 'Italic',
      'command': 'markdown-writer:toggle-italic-text'
    },
    { 'type': 'separator' },
    {
      'icon': 'format-list-bulleted',
      'label': 'Unordered List'
      'command': 'markdown-writer:toggle-ul'
    },
    {
      'icon': 'format-list-numbers',
      'label': 'Ordered List'
      'command': 'markdown-writer:toggle-ol'
    },
    { 'type': 'separator' },
    {
      'icon': 'format-header-1',
      'label': 'Heading 1'
      'command': 'markdown-writer:toggle-h1'
    },
    {
      'icon': 'format-header-2',
      'label': 'Heading 2'
      'command': 'markdown-writer:toggle-h2'
    },
    {
      'icon': 'format-header-3',
      'label': 'Heading 3'
      'command': 'markdown-writer:toggle-h3'
    },
    { 'type': 'separator' },
    {
      'icon': 'format-header-decrease',
      'label': 'Jump to Previous Heading'
      'command': 'markdown-writer:jump-to-previous-heading'
    },
    {
      'icon': 'format-header-increase',
      'label': 'Jump to Next Heading'
      'command': 'markdown-writer:jump-to-next-heading'
    },
    { 'type': 'separator' },
    {
      'icon': 'table',
      'label': 'Insert Table',
      'command': 'markdown-writer:insert-table'
    },
    {
      'icon': 'table-edit',
      'label': 'Format Table'
      'command': 'markdown-writer:format-table'
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

    @buttons.forEach (button) =>
      if button['type'] == 'separator'
        @toolBar.addSpacer()
      else
        @toolBar.addButton(
          icon: button['icon'],
          callback: button['command'],
          tooltip: button['label'],
          iconset: 'mdi')

  removeButtons: -> @toolBar?.removeItems()

  updateToolbarVisible: (visible) ->
    atom.config.set('tool-bar.visible', visible)

  isToolbarVisible: -> atom.config.get('tool-bar.visible')

  activate: ->
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

  isMarkdown: ->
    editor = atom.workspace.getActiveTextEditor()
    return false unless editor?

    grammars = atom.config.get('tool-bar-markdown-writer.grammars')
    return grammars.indexOf(editor.getGrammar().scopeName) >= 0

  deactivate: ->
    @subscriptions.dispose()
    @subscriptions = null
    @toolBar?.removeItems()
