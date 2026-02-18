

<div class="panel" id="customflags-form-panel">
    <div class="panel-heading">
        <i class="icon-flag"></i>
        {if $flag}
            {l s='Edit Flag' mod='customflags'}: <strong>{$flag.name|escape:'htmlall':'UTF-8'}</strong>
        {else}
            {l s='Add New Flag' mod='customflags'}
        {/if}
    </div>

    <form method="POST" action="{$list_url|escape:'htmlall':'UTF-8'}&action=editFlag{if $id_custom_flag}&id_custom_flag={$id_custom_flag|intval}{/if}" class="form-horizontal">
        <input type="hidden" name="id_custom_flag" value="{$id_custom_flag|intval}" />

        <div class="form-wrapper">

            <div class="form-group">
                <label class="control-label col-lg-3 required">
                    {l s='Flag Name' mod='customflags'}
                </label>
                <div class="col-lg-5">
                    <input type="text"
                           name="flag_name"
                           id="flag_name"
                           class="form-control"
                           value="{if $flag}{$flag.name|escape:'htmlall':'UTF-8'}{/if}"
                           required
                           maxlength="128"
                           placeholder="{l s='e.g. Bestseller, Eco, Limited Edition' mod='customflags'}" />
                </div>
            </div>


            <div class="form-group">
                <label class="control-label col-lg-3">
                    {l s='Background Color' mod='customflags'}
                </label>
                <div class="col-lg-2">
                    <div class="input-group">
                        <input type="color"
                               name="bg_color"
                               id="bg_color"
                               class="form-control"
                               value="{if $flag}{$flag.bg_color|escape:'htmlall':'UTF-8'}{else}#FF5722{/if}"
                               style="height: 38px; padding: 2px;" />
                        <span class="input-group-addon" id="bg_color_hex">{if $flag}{$flag.bg_color|escape:'htmlall':'UTF-8'}{else}#FF5722{/if}</span>
                    </div>
                </div>
            </div>


            <div class="form-group">
                <label class="control-label col-lg-3">
                    {l s='Text Color' mod='customflags'}
                </label>
                <div class="col-lg-2">
                    <div class="input-group">
                        <input type="color"
                               name="text_color"
                               id="text_color"
                               class="form-control"
                               value="{if $flag}{$flag.text_color|escape:'htmlall':'UTF-8'}{else}#FFFFFF{/if}"
                               style="height: 38px; padding: 2px;" />
                        <span class="input-group-addon" id="text_color_hex">{if $flag}{$flag.text_color|escape:'htmlall':'UTF-8'}{else}#FFFFFF{/if}</span>
                    </div>
                </div>
            </div>


            <div class="form-group">
                <label class="control-label col-lg-3">
                    {l s='Position' mod='customflags'}
                </label>
                <div class="col-lg-2">
                    <input type="number"
                           name="position"
                           id="position"
                           class="form-control"
                           value="{if $flag}{$flag.position|intval}{else}0{/if}"
                           min="0" />
                </div>
            </div>


            <div class="form-group">
                <label class="control-label col-lg-3">
                    {l s='Active' mod='customflags'}
                </label>
                <div class="col-lg-9">
                    <span class="switch prestashop-switch fixed-width-lg">
                        <input type="radio" name="active" id="active_on" value="1"
                            {if !$flag || $flag.active}checked="checked"{/if} />
                        <label for="active_on">{l s='Yes' mod='customflags'}</label>
                        <input type="radio" name="active" id="active_off" value="0"
                            {if $flag && !$flag.active}checked="checked"{/if} />
                        <label for="active_off">{l s='No' mod='customflags'}</label>
                        <a class="slide-button btn"></a>
                    </span>
                </div>
            </div>


            <div class="form-group">
                <label class="control-label col-lg-3">
                    {l s='Preview' mod='customflags'}
                </label>
                <div class="col-lg-9">
                    <div id="flag-preview" class="cf-flag-preview-box">
                        <span id="flag-preview-badge" style="
                            background-color: {if $flag}{$flag.bg_color|escape:'htmlall':'UTF-8'}{else}#FF5722{/if};
                            color: {if $flag}{$flag.text_color|escape:'htmlall':'UTF-8'}{else}#FFFFFF{/if};
                            padding: 6px 16px;
                            border-radius: 4px;
                            font-size: 13px;
                            font-weight: 700;
                            letter-spacing: 0.5px;
                            text-transform: uppercase;
                            display: inline-block;
                        ">
                            {if $flag}{$flag.name|escape:'htmlall':'UTF-8'}{else}{l s='Flag Name' mod='customflags'}{/if}
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="panel-footer">
            <a href="{$list_url|escape:'htmlall':'UTF-8'}" class="btn btn-default">
                <i class="process-icon-cancel"></i> {l s='Cancel' mod='customflags'}
            </a>
            <button type="submit" name="submitSaveFlag" class="btn btn-default pull-right">
                <i class="process-icon-save"></i> {l s='Save' mod='customflags'}
            </button>
        </div>
    </form>
</div>


<script type="text/javascript">
(function() {
    var $name = $('#flag_name');
    var $bg = $('#bg_color');
    var $txt = $('#text_color');
    var $badge = $('#flag-preview-badge');
    var $bgHex = $('#bg_color_hex');
    var $txtHex = $('#text_color_hex');

    function updatePreview() {
        var name = $name.val() || 'Flag Name';
        var bg = $bg.val() || '#FF5722';
        var txt = $txt.val() || '#FFFFFF';
        $badge.text(name);
        $badge.css('background-color', bg);
        $badge.css('color', txt);
        $bgHex.text(bg);
        $txtHex.text(txt);
    }

    $name.on('input keyup change', updatePreview);
    $bg.on('input change', updatePreview);
    $txt.on('input change', updatePreview);
})();
</script>


{if $id_custom_flag > 0}
<div class="panel" id="customflags-products-panel">
    <div class="panel-heading">
        <i class="icon-link"></i> {l s='Assigned Products' mod='customflags'}
        <span class="badge" id="assigned-count">{$assigned_products|count}</span>
    </div>


    <div class="cf-search-section">
        <div class="form-group">
            <div class="col-lg-12">
                <div class="cf-search-wrapper">
                    <div class="input-group">
                        <span class="input-group-addon"><i class="icon-search"></i></span>
                        <input type="text"
                               id="cf-product-search"
                               class="form-control"
                               placeholder="{l s='Search products by name or reference... (min. 2 characters)' mod='customflags'}"
                               autocomplete="off" />
                        <span class="input-group-addon cf-search-spinner" id="cf-search-spinner" style="display:none;">
                            <i class="icon-spin icon-spinner"></i>
                        </span>
                    </div>
                </div>
            </div>
        </div>


        <div id="cf-search-results" class="cf-search-results" style="display:none;">
            <div class="cf-results-header">
                <span id="cf-results-count"></span>
                <div>
                    <button type="button" class="btn btn-default btn-sm" id="cf-select-all">
                        <i class="icon-check-square-o"></i> {l s='Select All' mod='customflags'}
                    </button>
                    <button type="button" class="btn btn-success btn-sm" id="cf-assign-selected" disabled>
                        <i class="icon-plus"></i> {l s='Assign Selected' mod='customflags'} (<span id="cf-selected-count">0</span>)
                    </button>
                </div>
            </div>
            <div id="cf-results-list" class="cf-results-list"></div>
        </div>
    </div>

    <div class="cf-category-section form-horizontal">
        <div class="form-group">
            <label class="control-label col-lg-3">
                <i class="icon-folder-open"></i> {l s='Assign by Category' mod='customflags'}
            </label>
            <div class="col-lg-6">
                <div class="input-group">
                    <select id="cf-category-select" class="form-control">
                        <option value="">{l s='-- Select category --' mod='customflags'}</option>
                        {foreach from=$categories item=cat}
                            <option value="{$cat.id_category|intval}">
                                {$cat.name|escape:'htmlall':'UTF-8'}
                            </option>
                        {/foreach}
                    </select>
                    <span class="input-group-btn">
                        <button type="button" class="btn btn-info" id="cf-assign-category" disabled>
                            <i class="icon-plus"></i> {l s='Assign Category' mod='customflags'}
                        </button>
                    </span>
                </div>
                <p class="help-block">{l s='Assign this flag to all products in the selected category.' mod='customflags'}</p>
            </div>
        </div>
    </div>


    <div class="clearfix"></div>

    <div id="cf-assigned-products" class="cf-assigned-products">
        {if $assigned_products|count > 0}
            {foreach from=$assigned_products item=product}
                <div class="cf-assigned-product" data-id-product="{$product.id_product|intval}">
                    <div class="cf-product-info">
                        {if $product.image_url}
                            <img src="{$product.image_url|escape:'htmlall':'UTF-8'}" alt="" class="cf-product-thumb" />
                        {else}
                            <div class="cf-product-thumb cf-no-image"><i class="icon-picture-o"></i></div>
                        {/if}
                        <div class="cf-product-details">
                            <strong>{$product.name|escape:'htmlall':'UTF-8'}</strong>
                            {if $product.reference}
                                <small class="text-muted">REF: {$product.reference|escape:'htmlall':'UTF-8'}</small>
                            {/if}
                        </div>
                    </div>
                    <button type="button" class="btn btn-danger btn-sm cf-remove-product" data-id-product="{$product.id_product|intval}">
                        <i class="icon-trash"></i>
                    </button>
                </div>
            {/foreach}
        {else}
            <div class="alert alert-info cf-no-products-msg" id="cf-no-products-msg">
                {l s='No products assigned to this flag yet. Use the search above to find and assign products.' mod='customflags'}
            </div>
        {/if}
    </div>
</div>


<script type="text/javascript">
(function() {
    var ajaxUrl = '{$ajax_url|escape:"javascript":"UTF-8"}';
    var idFlag = {$id_custom_flag|intval};
    var texts = {
        confirm_remove: '{l s="Are you sure you want to remove this product from the flag?" mod="customflags" js=1}',
        no_results: '{l s="No products found matching your search." mod="customflags" js=1}',
        error: '{l s="An error occurred. Please try again." mod="customflags" js=1}',
        assigned_success: '{l s="Products assigned successfully!" mod="customflags" js=1}',
        removed_success: '{l s="Product removed from flag." mod="customflags" js=1}',
        no_products: '{l s="No products assigned to this flag yet. Use the search above to find and assign products." mod="customflags" js=1}'
    };

    var searchTimer = null;
    var selectedProducts = {};
    var isSearching = false;

    var $searchInput = $('#cf-product-search');
    var $searchResults = $('#cf-search-results');
    var $resultsList = $('#cf-results-list');
    var $resultsCount = $('#cf-results-count');
    var $assignBtn = $('#cf-assign-selected');
    var $selectedCount = $('#cf-selected-count');
    var $spinner = $('#cf-search-spinner');
    var $assignedContainer = $('#cf-assigned-products');
    var $assignedCountBadge = $('#assigned-count');

    function escapeHtml(str) {
        if (!str) return '';
        return $('<div/>').text(str).html();
    }

    function showNotification(message, type) {
        var cls = type === 'success' ? 'alert-success' : 'alert-danger';
        var $n = $('<div class="alert ' + cls + '"></div>')
            .text(message)
            .css({
                position: 'fixed', top: '80px', right: '20px', zIndex: 9999,
                minWidth: '300px', maxWidth: '450px',
                boxShadow: '0 4px 12px rgba(0,0,0,0.15)'
            });
        $('body').append($n);
        setTimeout(function() {
            $n.fadeOut(300, function() { $n.remove(); });
        }, 3000);
    }

    function updateSelectedCount() {
        var count = Object.keys(selectedProducts).length;
        $selectedCount.text(count);
        $assignBtn.prop('disabled', count === 0);
    }

    function updateAssignedCount() {
        $assignedCountBadge.text($assignedContainer.find('.cf-assigned-product').length);
    }

    function hideResults() {
        $searchResults.hide();
        selectedProducts = {};
        updateSelectedCount();
    }


    $searchInput.on('input', function() {
        clearTimeout(searchTimer);
        var query = $.trim($(this).val());
        if (query.length < 2) {
            hideResults();
            return;
        }
        searchTimer = setTimeout(function() {
            searchProducts(query);
        }, 300);
    });

    function searchProducts(query) {
        if (isSearching) return;
        isSearching = true;
        $spinner.show();

        $.ajax({
            url: ajaxUrl,
            type: 'GET',
            dataType: 'json',
            data: {
                ajax: 1,
                action: 'searchProducts',
                q: query,
                id_custom_flag: idFlag
            },
            success: function(response) {
                displayResults(response.products || []);
            },
            error: function(xhr, status, err) {
                console.error('CustomFlags AJAX error:', status, err, xhr.responseText);
                $resultsList.html('<div class="cf-no-results">Error: ' + escapeHtml(err || status) + '</div>');
                $searchResults.show();
            },
            complete: function() {
                isSearching = false;
                $spinner.hide();
            }
        });
    }

    function displayResults(products) {
        selectedProducts = {};
        updateSelectedCount();

        if (products.length === 0) {
            $resultsList.html('<div class="cf-no-results">' + escapeHtml(texts.no_results) + '</div>');
            $resultsCount.text(texts.no_results);
            $searchResults.show();
            return;
        }

        $resultsCount.text(products.length + ' product(s) found');
        var html = '';
        for (var i = 0; i < products.length; i++) {
            var p = products[i];
            var img = p.image_url
                ? '<img src="' + escapeHtml(p.image_url) + '" alt="" class="cf-result-thumb" />'
                : '<div class="cf-result-no-image"><i class="icon-picture-o"></i></div>';
            html += '<div class="cf-result-item" data-id="' + parseInt(p.id_product) + '">'
                + '<input type="checkbox" class="cf-result-checkbox" value="' + parseInt(p.id_product) + '" />'
                + img
                + '<div class="cf-result-info"><strong>' + escapeHtml(p.name) + '</strong>'
                + (p.reference ? '<small>REF: ' + escapeHtml(p.reference) + '</small>' : '')
                + '</div></div>';
        }
        $resultsList.html(html);
        $searchResults.show();
    }


    $resultsList.on('click', '.cf-result-item', function(e) {
        if ($(e.target).is('input')) return;
        var $cb = $(this).find('.cf-result-checkbox');
        $cb.prop('checked', !$cb.prop('checked')).trigger('change');
    });

    $resultsList.on('change', '.cf-result-checkbox', function() {
        var id = parseInt($(this).val());
        if ($(this).is(':checked')) {
            $(this).closest('.cf-result-item').addClass('selected');
            selectedProducts[id] = true;
        } else {
            $(this).closest('.cf-result-item').removeClass('selected');
            delete selectedProducts[id];
        }
        updateSelectedCount();
    });


    $(document).on('click', function(e) {
        if (!$(e.target).closest('#cf-search-results, #cf-product-search').length) {
            hideResults();
        }
    });


    $assignBtn.on('click', function() {
        var ids = Object.keys(selectedProducts);
        if (ids.length === 0) return;

        var $btn = $(this);
        $btn.prop('disabled', true).html('<i class="icon-spin icon-spinner"></i> Assigning...');

        $.ajax({
            url: ajaxUrl,
            type: 'POST',
            dataType: 'json',
            data: {
                ajax: 1,
                action: 'assignProducts',
                id_custom_flag: idFlag,
                'product_ids[]': ids
            },
            success: function(response) {
                if (response.success) {
                    showNotification(texts.assigned_success, 'success');
                    refreshAssigned(response.assigned_products);
                    hideResults();
                    $searchInput.val('');
                } else {
                    showNotification(response.error || texts.error, 'error');
                }
            },
            error: function() {
                showNotification(texts.error, 'error');
            },
            complete: function() {
                $btn.html('<i class="icon-plus"></i> Assign Selected (<span id="cf-selected-count">0</span>)');
                $selectedCount = $('#cf-selected-count');
                selectedProducts = {};
                updateSelectedCount();
            }
        });
    });

    var $selectAll = $('#cf-select-all');
    var allSelected = false;

    $selectAll.on('click', function() {
        allSelected = !allSelected;
        $resultsList.find('.cf-result-checkbox').each(function() {
            $(this).prop('checked', allSelected).trigger('change');
        });
        $(this).html(allSelected
            ? '<i class="icon-square-o"></i> {l s="Deselect All" mod="customflags" js=1}'
            : '<i class="icon-check-square-o"></i> {l s="Select All" mod="customflags" js=1}'
        );
    });

    var $categorySelect = $('#cf-category-select');
    var $categoryBtn = $('#cf-assign-category');

    $categorySelect.on('change', function() {
        $categoryBtn.prop('disabled', !$(this).val());
    });

    $categoryBtn.on('click', function() {
        var idCategory = parseInt($categorySelect.val());
        if (!idCategory) return;

        var catName = $categorySelect.find('option:selected').text().trim();
        if (!confirm('{l s="Assign this flag to ALL products in category" mod="customflags" js=1} "' + catName + '"?')) return;

        var $btn = $(this);
        $btn.prop('disabled', true).html('<i class="icon-spin icon-spinner"></i> {l s="Assigning..." mod="customflags" js=1}');

        $.ajax({
            url: ajaxUrl,
            type: 'POST',
            dataType: 'json',
            data: {
                ajax: 1,
                action: 'assignCategory',
                id_custom_flag: idFlag,
                id_category: idCategory
            },
            success: function(response) {
                if (response.success) {
                    showNotification(response.added + ' {l s="products assigned from category!" mod="customflags" js=1}', 'success');
                    refreshAssigned(response.assigned_products);
                } else {
                    showNotification(response.error || texts.error, 'error');
                }
            },
            error: function() {
                showNotification(texts.error, 'error');
            },
            complete: function() {
                $btn.html('<i class="icon-plus"></i> {l s="Assign Category" mod="customflags" js=1}');
                $categorySelect.val('').trigger('change');
            }
        });
    });


    $assignedContainer.on('click', '.cf-remove-product', function() {
        if (!confirm(texts.confirm_remove)) return;

        var $row = $(this).closest('.cf-assigned-product');
        var idProduct = parseInt($(this).data('id-product'));
        $row.css({ opacity: 0.5 });

        $.ajax({
            url: ajaxUrl,
            type: 'POST',
            dataType: 'json',
            data: {
                ajax: 1,
                action: 'removeProduct',
                id_custom_flag: idFlag,
                id_product: idProduct
            },
            success: function(response) {
                if (response.success) {
                    $row.slideUp(300, function() {
                        $row.remove();
                        updateAssignedCount();
                        if ($assignedContainer.find('.cf-assigned-product').length === 0) {
                            $assignedContainer.html('<div class="alert alert-info cf-no-products-msg">' + escapeHtml(texts.no_products) + '</div>');
                        }
                    });
                    showNotification(texts.removed_success, 'success');
                }
            },
            error: function() {
                $row.css({ opacity: 1 });
                showNotification(texts.error, 'error');
            }
        });
    });

    function refreshAssigned(products) {
        $assignedContainer.find('.cf-no-products-msg').remove();
        var html = '';
        for (var i = 0; i < products.length; i++) {
            var p = products[i];
            var img = p.image_url
                ? '<img src="' + escapeHtml(p.image_url) + '" alt="" class="cf-product-thumb" />'
                : '<div class="cf-product-thumb cf-no-image"><i class="icon-picture-o"></i></div>';
            html += '<div class="cf-assigned-product" data-id-product="' + parseInt(p.id_product) + '">'
                + '<div class="cf-product-info">' + img
                + '<div class="cf-product-details"><strong>' + escapeHtml(p.name) + '</strong>'
                + (p.reference ? '<small class="text-muted">REF: ' + escapeHtml(p.reference) + '</small>' : '')
                + '</div></div>'
                + '<button type="button" class="btn btn-danger btn-sm cf-remove-product" data-id-product="' + parseInt(p.id_product) + '">'
                + '<i class="icon-trash"></i></button></div>';
        }
        $assignedContainer.html(html);
        updateAssignedCount();
    }
})();
</script>
{/if}
