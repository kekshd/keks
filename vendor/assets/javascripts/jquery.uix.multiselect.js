/*
 * jQuery UIx Multiselect 2.0
 *
 * Authors:
 *  Yanick Rochon (yanick.rochon[at]gmail[dot]com)
 *
 * Licensed under the MIT (MIT-LICENSE.txt) license.
 *
 * http://mind2soft.com/labs/jquery/multiselect/
 *
 *
 * Depends:
 * jQuery UI 1.8+
 *
 */

;(function($, window, undefined) {
    // ECMAScript 5 Strict Mode: [John Resig Blog Post](http://ejohn.org/blog/ecmascript-5-strict-mode-json-and-more/)
    "use strict";

    // Each instance must have their own drag and drop scope. We use a global page scope counter
    // so we do not create two instances with mistankenly the same scope! We do not support
    // cross instance drag and drop; this would require also copying the OPTION element and it
    // would slow the component down. This is not the widget's contract anyhow.
    var globalScope = 0;

    var DEF_OPTGROUP = '';
    var PRE_OPTGROUP = 'group-';

    // these events will trigger on the original element
    //var NATIVE_EVENTS = ["change"];   // for version 2.1

    // a list of predefined events
    //var EVENT_CHANGE = 'change';    // for version 2.1
    var EVENT_CHANGE = 'multiselectChange';

    // The jQuery.uix namespace will automatically be created if it doesn't exist
    $.widget("uix.multiselect", {
        options: {
            availableListPosition: 'right',// 'top', 'right', 'bottom', 'left'; the position of the available list (default: 'right')
            collapsableGroups: true,       // tells whether the option groups can be collapsed or not (default: true)
            created: null,                 // a function called when the widget is done loading (default: null)
            defaultGroupName: '',          // the name of the default option group (default: '')
            moveEffect: null,              // 'blind','bounce','clip','drop','explode','fold','highlight','puff','pulsate','shake','slide' (default: null)
            moveEffectOptions: {},         // effect options (see jQuery UI documentation) (default: {})
            moveEffectSpeed: null,         // string ('slow','fast') or number in millisecond (ignored if moveEffect is 'show') (default: null)
            optionRenderer: false,         // a function that will return the item element to be rendered in the list (default: false)
            optionGroupRenderer: false,    // a function that will return the group item element to be rendered (default: false)
            selectionMode: 'click',    // how options can be selected separated by commas: 'click', "dblclick"
            showDefaultGroupHeader: false, // show the default option group header (default: false)
            showEmptyGroups: false,        // always display option groups even if empty (default: false)
            splitRatio: 0.55,              // % of the left list's width of the widget total width (default 0.55)
            selectAll: 'both',             // 'available', 'selected', 'both', 'none' - Whether or not to display a select or deselect all icon (default: 'both')
            height: 400,
            width: 900
        },

        _create: function() {
            var that = this;
            var selListHeader, selListContent, avListHeader, avListContent;
            var btnSelectAll, btnDeselectAll;

            this.scope = 'multiselect' + (globalScope++);
            this.optionGroupIndex = 1;

            this.element.addClass('uix-multiselect-original');
            this._elementWrapper = $(document.createElement('div')).addClass('uix-multiselect ui-widget')
                .css({
                  width: this.element.css('width'),
                  height: this.element.css('height')
                })
                .append(
                    $(document.createElement('div')).addClass('multiselect-selected-list')
                        .append( $(document.createElement('div')).addClass('ui-widget-header')
                            .append( btnDeselectAll = $('<button></button>', { type:"button" }).addClass('uix-control-right')
                                .attr('title', 'Deselect All')
                                .button({icons:{primary:'ui-icon-arrowthickstop-1-e'}, text:false})
                                .click(function(e) { e.preventDefault(); e.stopPropagation(); that.optionCache.setSelectedAll(false); return false; })
                                ['both,selected'.indexOf(this.options.selectAll)>=0 ? 'show' : 'hide']()
                            )
                            .append( selListHeader = $(document.createElement('div')).addClass('header-text') )
                        )
                        .append( selListContent = $(document.createElement('div')).addClass('uix-list-container ui-widget-content') )
                )
                ['right,top'.indexOf(this.options.availableListPosition)>=0?'prepend':'append'](
                    $(document.createElement('div')).addClass('multiselect-available-list')
                        .append( $(document.createElement('div')).addClass('ui-widget-header')
                            .append( btnSelectAll = $('<button></button>', { type:"button" }).addClass('uix-control-right')
                                .attr('title', 'Select All')
                                .button({icons:{primary:'ui-icon-arrowthickstop-1-w'}, text:false})
                                .click(function(e) { e.preventDefault(); e.stopPropagation(); that.optionCache.setSelectedAll(true); return false; })
                                ['both,available'.indexOf(this.options.selectAll)>=0 ? 'show' : 'hide']()
                            )
                            .append( avListHeader = $(document.createElement('div')).addClass('header-text') )

                        )
                        .append( avListContent  = $(document.createElement('div')).addClass('uix-list-container ui-widget-content') )
                )
                .insertAfter(this.element)
            ;

            this._buttons = {
                'selectAll': btnSelectAll,
                'deselectAll': btnDeselectAll
            };
            this._headers = {
                'selected': selListHeader,
                'available': avListHeader
            };
            this._lists = {
                'selected': selListContent.attr('id', this.scope+'_selListContent'),
                'available': avListContent.attr('id', this.scope+'_avListContent')
            };

            this.optionCache = new OptionCache(this);

            this.refresh(this.options.created);
        },

        /**
         * ***************************************
         *   PUBLIC
         * ***************************************
         */

        /**
         * Refresh all the lists from the underlaying element. This method is executed
         * asynchronously from the call, therefore it returns immediately. However, the
         * method accepts a callback parameter which will be executed when the refresh is
         * complete.
         *
         * @param callback   function    a callback function called when the refresh is complete
         */
        refresh: function(callback) {
            this._resize();  // just make sure we display the widget right without delay
            asyncFunction(function() {
                this.optionCache.cleanup();

                var opt, options = this.element[0].childNodes;

                for (var i=0, l1=options.length; i<l1; i++) {
                    opt = options[i];
                    if (opt.nodeType === 1) {
                        if (opt.tagName.toUpperCase() === 'OPTGROUP') {
                            var optGroup = $(opt).data('option-group') || (PRE_OPTGROUP + (this.optionGroupIndex++));
                            var grpOptions = opt.childNodes;

                            this.optionCache.prepareGroup($(opt), optGroup);

                            for (var j=0, l2=grpOptions.length; j<l2; j++) {
                                opt = grpOptions[j];
                                if (opt.nodeType === 1) {
                                    this.optionCache.prepareOption($(opt), optGroup);
                                }
                            }
                        } else {
                            this.optionCache.prepareOption($(opt));  // add to default group
                        }
                    }
                }

                this.optionCache.reIndex();

                if (callback) callback();
            }, 10, this);

        },


        /**
         * ***************************************
         *   PRIVATE
         * ***************************************
         */

        _updateHeaders: function() {
            var t, info = this.optionCache.getSelectionInfo();

            this._headers['selected']
                .text( t = (info.selected.total + ' selected option(s)') )
                .parent().attr('title', t);
            this._headers['available']
                .text( info.available.total + ' option(s) available')
                .parent().attr('title',
                    info.available.count + ' option(s) available');
        },

        // call this method whenever the widget resizes
        // NOTE : the widget MUST be visible and have a width and height when calling this
        _resize: function() {
            var pos = this.options.availableListPosition.toLowerCase();         // shortcut
            var cSl = this.options.width * this.options.splitRatio;  // list container size selected
            var cAv = this.options.width - cSl;                      // ... available
            var styleRule = ('left,right'.indexOf(pos) >= 0) ? 'left' : 'top';  // CSS rule for offsetting
            var headerBordersBoth = 'ui-corner-tl ui-corner-tr ui-corner-bl ui-corner-br ui-corner-top';

            // calculate outer lists dimensions
            this._elementWrapper.find('.multiselect-available-list')
                ['width'](cAv).css(styleRule, cSl)
                ['height'](this.options.height + 1);  // account for borders
            this._elementWrapper.find('.multiselect-selected-list')
                ['width'](cSl).css(styleRule, 0)
                ['height'](this.options.height + 1); // account for borders

            // selection all button
            this._buttons['selectAll'].button('option', 'icons', {primary: transferIcon(pos, 'ui-icon-arrowthickstop-1-', false) });
            this._buttons['deselectAll'].button('option', 'icons', {primary: transferIcon(pos, 'ui-icon-arrowthickstop-1-', true) });

            // calculate inner lists height
            // 22 = this._headers['available'].parent().outerHeight()  cached value to save one reflow
            this._lists['available'].height(this.options.height - 22 - 2);  // account for borders
            this._lists['selected'].height(this.options.height - 22 - 2);    // account for borders
        },

        /**
         * return false if the event was prevented by an handler, true otherwise
         */
        _triggerUIEvent: function(event, ui) {
            var eventType;

            if (typeof event === 'string') {
                eventType = event;
                event = $.Event(event);
            } else {
                eventType = event.type;
            }

            //console.log($.inArray(event.type, NATIVE_EVENTS));

            //if ($.inArray(event.type, NATIVE_EVENTS) > -1) {
                this.element.trigger(event, ui);
            //} else {
            //    this._trigger(eventType, event, ui);
            //}

            return !event.isDefaultPrevented();
        },

        _setOption: function(key, value) {

            if (typeof(this._superApply) == 'function'){
                this._superApply(arguments);
            }else{
                $.Widget.prototype._setOption.apply(this, arguments);
            }
        }
    });

    var transferDirection = ['n','e','s','w'];                          // button icon direction
    var transferOrientation = ['bottom','left','top','right'];    // list of matching directions with icons
    var transferIcon = function(pos, prefix, selected) {
        return prefix + transferDirection[($.inArray(pos.toLowerCase(), transferOrientation) + (selected ? 2 : 0)) % 4];
    };

    /**
     * setTimeout on steroids!
     */
    var asyncFunction = function(callback, timeout, self) {
        var args = Array.prototype.slice.call(arguments, 3);
        return setTimeout(function() {
            callback.apply(self || window, args);
        }, timeout);
    };

    /**
     * Map of all option groups
     */
    var GroupCache = function(comp) {
        // private members

        var keys = [];
        var items = {};

        // public methods

        this.clear = function() {
            keys = [];
            items = {};
            return this;
        };

        this.containsKey = function(key) {
            return !!items[key];
        };

        this.get = function(key) {
            return items[key];
        };

        this.put = function(key, val) {
            if (!items[key]) {
                keys.push(key);
            }

            items[key] = val;
            return this;
        };

        this.remove = function(key) {
            delete items[key];
            return keys.splice(keys.indexOf(key), 1);
        };

        this.each = function(callback) {
            var args = Array.prototype.slice.call(arguments, 1);
            args.splice(0, 0, null, null);
            for (var i=0, len=keys.length; i<len; i++) {
                args[0] = keys[i];
                args[1] = items[keys[i]];
                callback.apply(args[1], args);
            }
            return this;
        };

    };

    var OptionCache = function(widget) {
        this._widget = widget;
        this._listContainers = {
            'selected': $(document.createElement('div')).appendTo(this._widget._lists['selected']),
            'available': $(document.createElement('div')).appendTo(this._widget._lists['available'])
        };

        this._elements = [];
        this._groups = new GroupCache();

        this._moveEffect = {
            fn: widget.options.moveEffect,
            options: widget.options.moveEffectOptions,
            speed: widget.options.moveEffectSpeed
        };

        this._selectionMode = this._widget.options.selectionMode.indexOf('dblclick') > -1 ? 'dblclick'
                            : this._widget.options.selectionMode.indexOf('click') > -1 ? 'click' : false;
    };

    OptionCache.prototype = {
        _createGroupElement: function(grpElement, optGroup, selected) {
            var that = this;
            var gData;

            var getLocalData = function() {
                if (!gData) gData = that._groups.get(optGroup);
                return gData;
            };

            var getGroupName = function() {
                return grpElement ? grpElement.attr('label') : that._widget.options.defaultGroupName;
            };

            var labelCount = $(document.createElement('span')).addClass('label');
                // .text(getGroupName() + ' (0)');

            var fnUpdateCount = function() {
                var gDataDst = getLocalData()[selected?'selected':'available'];

                gDataDst.listElement[(!selected && (gDataDst.count || that._widget.options.showEmptyGroups)) || (gDataDst.count && ((gData.optionGroup != DEF_OPTGROUP) || that._widget.options.showDefaultGroupHeader)) ? 'show' : 'hide']();

                var t = getGroupName() + ' (' + gDataDst.count + ')';
                labelCount.text(t);
            };

            var e = $(document.createElement('div'))
                .addClass('ui-widget-header ui-priority-secondary group-element')
                .append( $('<button></button>', { type:"button" }).addClass('uix-control-right')
                    .attr('title', (selected?'de':'')+' select all group')
                    .button({icons:{primary:transferIcon(this._widget.options.availableListPosition, 'ui-icon-arrowstop-1-', selected)}, text:false})
                    .click(function(e) {
                        e.preventDefault(); e.stopPropagation();

                        var gDataDst = getLocalData()[selected?'selected':'available'];

                        if (gData.count > 0) {
                            var _transferedOptions = [];

                            for (var i=gData.startIndex, len=gData.startIndex+gData.count, eData; i<len; i++) {
                                eData = that._elements[i];
                                if ( !eData.selected != selected) {
                                    that.setSelected(eData, !selected, true);
                                    _transferedOptions.push(eData.optionElement[0]);
                                }
                            }

                            that._updateGroupElements(gData);
                            that._widget._updateHeaders();

                            that._widget._triggerUIEvent(EVENT_CHANGE, { optionElements:_transferedOptions, selected:!selected} );
                        }

                        return false;
                    })
                )
                .append(labelCount)
            ;

            var fnToggle,
                groupIcon = (grpElement) ? grpElement.attr('data-group-icon') : null;


            var collapseIconAttr = (grpElement) ? grpElement.attr('data-collapse-icon') : null,
                grpExpandIcon = (collapseIconAttr) ? 'ui-icon ' + collapseIconAttr : 'ui-icon ui-icon-triangle-1-e';
            var h = $(document.createElement('span')).addClass('ui-icon collapse-handle')
                .attr('title', 'Collapse Group')
                .addClass(grpExpandIcon)
                .mousedown(function(e) { e.stopPropagation(); })
                .click(function(e) { e.preventDefault(); e.stopPropagation(); fnToggle(grpElement); return false; })
                .prependTo(e.addClass('group-element-collapsable'))
            ;

            fnToggle = function(grpElement) {
                var gDataDst = getLocalData()[selected?'selected':'available'],
                    collapseIconAttr = (grpElement) ? grpElement.attr('data-collapse-icon') : null,
                    expandIconAttr = (grpElement) ? grpElement.attr('data-expand-icon') : null,
                    collapseIcon = (collapseIconAttr) ? 'ui-icon ' + collapseIconAttr : 'ui-icon ui-icon-triangle-1-s',
                    expandIcon = (expandIconAttr) ? 'ui-icon ' + expandIconAttr : 'ui-icon ui-icon-triangle-1-e';
                gDataDst.collapsed = !gDataDst.collapsed;
                gDataDst.listContainer.slideToggle();  // animate options?
                h.removeClass(gDataDst.collapsed ? collapseIcon : expandIcon)
                 .addClass(gDataDst.collapsed ? expandIcon : collapseIcon);
            };

            return $(document.createElement('div'))
                // create an utility function to update group element count
                .data('fnUpdateCount', fnUpdateCount)
                .data('fnToggle', fnToggle)
                .append(e)
            ;
        },

        _createGroupContainerElement: function(grpElement, optGroup, selected) {
            var that = this;
            var e = $('<div style="display:none"></div>');
            var _received_index;

            if (this._selectionMode) {
                $(e).on(this._selectionMode, 'div.option-element', function() {
                    var eData = that._elements[$(this).data('element-index')];
                    that.setSelected(eData, !selected);
                });
            }

            return e;
        },

        _createElement: function(optElement, optGroup) {
            var d = document.createElement('div');
            d.appendChild(document.createTextNode(optElement.text()));
            d.setAttribute('class', 'ui-state-default option-element');
            return $(d);
        },

        _isOptionCollapsed: function(eData) {
            return this._groups.get(eData.optionGroup)[eData.selected?'selected':'available'].collapsed;
        },

        _updateGroupElements: function(gData) {
            if (gData) {
                gData['selected'].count = 0;
                gData['available'].count = 0;
                for (var i=gData.startIndex, len=gData.startIndex+gData.count; i<len; i++) {
                    gData[this._elements[i].selected?'selected':'available'].count++;
                }
                gData['selected'].listElement.data('fnUpdateCount')();
                gData['available'].listElement.data('fnUpdateCount')();
            } else {
                this._groups.each(function(k,gData,that) {
                    that._updateGroupElements(gData);
                }, this);
            }
        },

        _appendToList: function(eData) {
            var that = this;
            var gData = this._groups.get(eData.optionGroup);

            var gDataDst = gData[eData.selected?'selected':'available'];

            var insertIndex = eData.index - 1;
            while ((insertIndex >= gData.startIndex) &&
                   (this._elements[insertIndex].selected != eData.selected)) {
                insertIndex--;
            }

            if (insertIndex < gData.startIndex) {
                gDataDst.listContainer.prepend(eData.listElement);
            } else {
                var prev = this._elements[insertIndex].listElement;
                eData.listElement.insertAfter(prev);
            }
        },

        // should call _reIndex after this
        cleanup: function() {
            this.prepareGroup();  // make sure we have the default group still!
        },

        // prepare option group to be rendered (should call reIndex after this!)
        prepareGroup: function(grpElement, optGroup) {
            optGroup = optGroup || DEF_OPTGROUP;
            if (!this._groups.containsKey(optGroup)) {
                this._groups.put(optGroup, {
                    startIndex: -1,
                    count: 0,
                    'selected': {
                        collapsed: true,
                        count: 0,
                        listElement: this._createGroupElement(grpElement, optGroup, true),
                        listContainer: this._createGroupContainerElement(grpElement, optGroup, true)
                    },
                    'available': {
                        collapsed: true,
                        count: 0,
                        listElement: this._createGroupElement(grpElement, optGroup, false),
                        listContainer: this._createGroupContainerElement(grpElement, optGroup, false)
                    },
                    groupElement: grpElement,
                    optionGroup: optGroup     // for back ref
                });
            }
        },

        // prepare option element to be rendered (must call reIndex after this!)
        // If optGroup is defined, prepareGroup(optGroup) should have been called already
        prepareOption: function(optElement, optGroup) {
            optGroup = optGroup || DEF_OPTGROUP;
            this._elements.push({
                index: -1,
                //selected: false,
                listElement: this._createElement(optElement, optGroup),
                optionElement: optElement,
                optionGroup: optGroup
            });
        },

        reIndex: function() {
            this._groups.each(function(g, v, l, showDefGroupName) {
                // Hack: only called once, don’t actually check
                //if (!v['available'].listContainer.parents('.multiselect-element-wrapper').length) {  // if no parent, then it was never attached yet.
                    if (v.groupElement) {
                        v.groupElement.data('option-group', g);  // for back ref
                    }

                    var wrapper_selected = $(document.createElement('div')).addClass('multiselect-element-wrapper').data('option-group', g);
                    var wrapper_available = $(document.createElement('div')).addClass('multiselect-element-wrapper').data('option-group', g);
                    wrapper_selected.append(v.selected.listElement/*.hide()*/);
                    if (g != DEF_OPTGROUP || (g == DEF_OPTGROUP && showDefGroupName)) {
                        wrapper_available.append(v['available'].listElement.show());
                    }
                    wrapper_selected.append(v['selected'].listContainer);
                    wrapper_available.append(v['available'].listContainer);

                    l['selected'].append(wrapper_selected);
                    l['available'].append(wrapper_available);
                //}
                v.count = 0;
            }, this._listContainers, this._widget.options.showDefaultGroupHeader);

            for (var i=0, eData, gData, len=this._elements.length; i<len; i++) {
                eData = this._elements[i];
                gData = this._groups.get(eData.optionGroup);

                // update group index and count info
                if (gData.startIndex == -1 || gData.startIndex >= i) {
                    gData.startIndex = i;
                    gData.count = 1;
                } else {
                    gData.count++;
                }

                // save element index for back ref
                eData.listElement.data('element-index', eData.index = i);

                if (eData.optionElement.data('element-index') == undefined || eData.selected != eData.optionElement.prop('selected')) {
                    eData.selected = eData.optionElement.prop('selected');
                    eData.optionElement.data('element-index', i);  // also save for back ref here

                    this._appendToList(eData);
                }
            }

            this._updateGroupElements();
            this._widget._updateHeaders();
        },


        getSelectionInfo: function() {
            var info = {'selected': {'total': 0, 'count': 0}, 'available': {'total': 0, 'count': 0} };

            for (var i=0, len=this._elements.length; i<len; i++) {
                var eData = this._elements[i];
                info[eData.selected?'selected':'available']['count']++;
                info[eData.selected?'selected':'available'].total++;
            }

            return info;
        },

        setSelected: function(eData, selected, silent) {
            eData.optionElement.prop('selected', eData.selected = selected);

            this._appendToList(eData);

            if (!silent) {
                this._updateGroupElements(this._groups.get(eData.optionGroup));
                this._widget._updateHeaders();
                this._widget._triggerUIEvent(EVENT_CHANGE, { optionElements:[eData.optionElement[0]], selected:selected } );
            }
        },

        // utility function to select all options
        setSelectedAll: function(selected) {
            var _transferedOptions = [];
            var _modifiedGroups = {};

            for (var i=0, eData, len=this._elements.length; i<len; i++) {
                eData = this._elements[i];
                if (!((eData.selected == selected) || (selected && eData.selected))) {
                    this.setSelected(eData, selected, true);
                    _transferedOptions.push(eData.optionElement[0]);
                    _modifiedGroups[eData.optionGroup] = true;
                }
            }


            this._updateGroupElements();
            this._widget._updateHeaders();

            this._widget._triggerUIEvent(EVENT_CHANGE, { optionElements:_transferedOptions, selected:selected } );
        }

    };

})(jQuery, window);
