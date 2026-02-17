(function () {
    'use strict';

    if (typeof customflags_config === 'undefined') {
        return;
    }

    var config = customflags_config;
    var searchTimer = null;
    var selectedProducts = {};
    var isSearching = false;

    function init() {
        var searchInput = document.getElementById('cf-product-search');
        var searchResults = document.getElementById('cf-search-results');
        var resultsList = document.getElementById('cf-results-list');
        var resultsCount = document.getElementById('cf-results-count');
        var assignBtn = document.getElementById('cf-assign-selected');
        var selectedCountEl = document.getElementById('cf-selected-count');
        var searchSpinner = document.getElementById('cf-search-spinner');
        var assignedContainer = document.getElementById('cf-assigned-products');
        var assignedCountBadge = document.getElementById('assigned-count');

        var flagNameInput = document.getElementById('flag_name');
        var bgColorInput = document.getElementById('bg_color');
        var textColorInput = document.getElementById('text_color');
        var previewBadge = document.getElementById('flag-preview-badge');
        var bgColorHex = document.getElementById('bg_color_hex');
        var textColorHex = document.getElementById('text_color_hex');

        function updatePreview() {
            if (!previewBadge) return;

            var name = flagNameInput ? flagNameInput.value : 'Flag Name';
            var bg = bgColorInput ? bgColorInput.value : '#FF5722';
            var txt = textColorInput ? textColorInput.value : '#FFFFFF';

            previewBadge.textContent = name || 'Flag Name';
            previewBadge.style.backgroundColor = bg;
            previewBadge.style.color = txt;

            if (bgColorHex) bgColorHex.textContent = bg;
            if (textColorHex) textColorHex.textContent = txt;
        }

        if (flagNameInput) {
            flagNameInput.addEventListener('input', updatePreview);
            flagNameInput.addEventListener('keyup', updatePreview);
            flagNameInput.addEventListener('change', updatePreview);
        }
        if (bgColorInput) {
            bgColorInput.addEventListener('input', updatePreview);
            bgColorInput.addEventListener('change', updatePreview);
        }
        if (textColorInput) {
            textColorInput.addEventListener('input', updatePreview);
            textColorInput.addEventListener('change', updatePreview);
        }

        function showSpinner(show) {
            if (searchSpinner) {
                searchSpinner.style.display = show ? 'table-cell' : 'none';
            }
        }

        function hideResults() {
            if (searchResults) {
                searchResults.style.display = 'none';
            }
            selectedProducts = {};
            updateSelectedCount();
        }

        function updateSelectedCount() {
            var count = Object.keys(selectedProducts).length;
            if (selectedCountEl) {
                selectedCountEl.textContent = count;
            }
            if (assignBtn) {
                assignBtn.disabled = count === 0;
            }
        }

        function updateAssignedCount() {
            if (assignedCountBadge && assignedContainer) {
                var count = assignedContainer.querySelectorAll('.cf-assigned-product').length;
                assignedCountBadge.textContent = count;
            }
        }

        function escapeHtml(str) {
            if (!str) return '';
            var div = document.createElement('div');
            div.appendChild(document.createTextNode(str));
            return div.innerHTML;
        }

        function showNotification(message, type) {
            var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
            var notif = document.createElement('div');
            notif.className = 'alert ' + alertClass;
            notif.style.cssText = 'position:fixed;top:80px;right:20px;z-index:9999;min-width:300px;max-width:450px;box-shadow:0 4px 12px rgba(0,0,0,0.15);';
            notif.textContent = message;
            document.body.appendChild(notif);
            setTimeout(function () {
                notif.style.opacity = '0';
                notif.style.transition = 'opacity 0.3s ease';
                setTimeout(function () { notif.remove(); }, 300);
            }, 3000);
        }

        function searchProducts(query) {
            if (isSearching) return;
            isSearching = true;
            showSpinner(true);

            var xhr = new XMLHttpRequest();
            var url = config.ajax_url
                + '&ajax=1&action=searchProducts'
                + '&q=' + encodeURIComponent(query)
                + '&id_custom_flag=' + config.id_custom_flag;

            xhr.open('GET', url, true);
            xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    isSearching = false;
                    showSpinner(false);

                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText);
                            displayResults(response.products || []);
                        } catch (e) {
                            console.error('CustomFlags: Parse error', e);
                            console.error('CustomFlags: Response was:', xhr.responseText);
                        }
                    } else {
                        console.error('CustomFlags: Request failed', xhr.status);
                    }
                }
            };

            xhr.send();
        }

        function displayResults(products) {
            if (!resultsList || !searchResults) return;

            selectedProducts = {};
            updateSelectedCount();

            if (products.length === 0) {
                resultsList.innerHTML = '<div class="cf-no-results">' + escapeHtml(config.texts.no_results) + '</div>';
                if (resultsCount) resultsCount.textContent = config.texts.no_results;
                searchResults.style.display = 'block';
                return;
            }

            if (resultsCount) resultsCount.textContent = products.length + ' product(s) found';

            var html = '';
            for (var i = 0; i < products.length; i++) {
                var p = products[i];
                var imageHtml = p.image_url
                    ? '<img src="' + escapeHtml(p.image_url) + '" alt="" class="cf-result-thumb" />'
                    : '<div class="cf-result-no-image"><i class="icon-picture-o"></i></div>';

                html += '<div class="cf-result-item" data-id-product="' + parseInt(p.id_product) + '">'
                    + '<input type="checkbox" class="cf-result-checkbox" data-id-product="' + parseInt(p.id_product) + '" />'
                    + imageHtml
                    + '<div class="cf-result-info">'
                    + '<strong>' + escapeHtml(p.name) + '</strong>'
                    + (p.reference ? '<small>REF: ' + escapeHtml(p.reference) + '</small>' : '')
                    + '</div>'
                    + '</div>';
            }

            resultsList.innerHTML = html;
            searchResults.style.display = 'block';

            var items = resultsList.querySelectorAll('.cf-result-item');
            for (var j = 0; j < items.length; j++) {
                (function (item) {
                    item.addEventListener('click', function (e) {
                        if (e.target.tagName === 'INPUT') return;
                        var checkbox = item.querySelector('.cf-result-checkbox');
                        checkbox.checked = !checkbox.checked;
                        toggleSelection(item, checkbox);
                    });

                    var cb = item.querySelector('.cf-result-checkbox');
                    cb.addEventListener('change', function () {
                        toggleSelection(item, cb);
                    });
                })(items[j]);
            }
        }

        function toggleSelection(item, checkbox) {
            var idProduct = parseInt(checkbox.getAttribute('data-id-product'));
            if (checkbox.checked) {
                item.classList.add('selected');
                selectedProducts[idProduct] = true;
            } else {
                item.classList.remove('selected');
                delete selectedProducts[idProduct];
            }
            updateSelectedCount();
        }

        function assignSelectedProducts() {
            var ids = Object.keys(selectedProducts);
            if (ids.length === 0) return;

            assignBtn.disabled = true;
            assignBtn.innerHTML = '<i class="icon-spin icon-spinner"></i> Assigning...';

            var xhr = new XMLHttpRequest();
            var url = config.ajax_url + '&ajax=1&action=assignProducts';

            xhr.open('POST', url, true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    assignBtn.innerHTML = '<i class="icon-plus"></i> Assign Selected (<span id="cf-selected-count">0</span>)';
                    selectedCountEl = document.getElementById('cf-selected-count');

                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                showNotification(config.texts.assigned_success, 'success');
                                refreshAssignedProducts(response.assigned_products);
                                hideResults();
                                if (searchInput) searchInput.value = '';
                                selectedProducts = {};
                                updateSelectedCount();
                            } else {
                                showNotification(response.error || config.texts.error, 'error');
                            }
                        } catch (e) {
                            showNotification(config.texts.error, 'error');
                        }
                    } else {
                        showNotification(config.texts.error, 'error');
                    }
                }
            };

            var data = 'id_custom_flag=' + config.id_custom_flag;
            for (var i = 0; i < ids.length; i++) {
                data += '&product_ids[]=' + ids[i];
            }

            xhr.send(data);
        }

        function removeProduct(idProduct, element) {
            if (!confirm(config.texts.confirm_remove)) {
                return;
            }

            element.classList.add('cf-removing');

            var xhr = new XMLHttpRequest();
            var url = config.ajax_url + '&ajax=1&action=removeProduct';

            xhr.open('POST', url, true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText);
                            if (response.success) {
                                setTimeout(function () {
                                    element.remove();
                                    updateAssignedCount();
                                    showNotification(config.texts.removed_success, 'success');

                                    var remaining = assignedContainer.querySelectorAll('.cf-assigned-product');
                                    if (remaining.length === 0) {
                                        assignedContainer.innerHTML = '<div class="alert alert-info cf-no-products-msg">'
                                            + escapeHtml(config.texts.no_products) + '</div>';
                                    }
                                }, 300);
                            }
                        } catch (e) {
                            element.classList.remove('cf-removing');
                            showNotification(config.texts.error, 'error');
                        }
                    } else {
                        element.classList.remove('cf-removing');
                        showNotification(config.texts.error, 'error');
                    }
                }
            };

            xhr.send('id_custom_flag=' + config.id_custom_flag + '&id_product=' + idProduct);
        }

        function refreshAssignedProducts(products) {
            if (!assignedContainer) return;

            var noMsg = assignedContainer.querySelector('.cf-no-products-msg');
            if (noMsg) noMsg.remove();

            var html = '';
            for (var i = 0; i < products.length; i++) {
                var p = products[i];
                var imageHtml = p.image_url
                    ? '<img src="' + escapeHtml(p.image_url) + '" alt="" class="cf-product-thumb" />'
                    : '<div class="cf-product-thumb cf-no-image"><i class="icon-picture-o"></i></div>';

                html += '<div class="cf-assigned-product cf-new-item" data-id-product="' + parseInt(p.id_product) + '">'
                    + '<div class="cf-product-info">'
                    + imageHtml
                    + '<div class="cf-product-details">'
                    + '<strong>' + escapeHtml(p.name) + '</strong>'
                    + (p.reference ? '<small class="text-muted">REF: ' + escapeHtml(p.reference) + '</small>' : '')
                    + '</div>'
                    + '</div>'
                    + '<button type="button" class="btn btn-danger btn-sm cf-remove-product" data-id-product="' + parseInt(p.id_product) + '">'
                    + '<i class="icon-trash"></i>'
                    + '</button>'
                    + '</div>';
            }

            assignedContainer.innerHTML = html;
            updateAssignedCount();
        }

        if (searchInput) {
            searchInput.addEventListener('input', function () {
                clearTimeout(searchTimer);
                var query = this.value.trim();

                if (query.length < 2) {
                    hideResults();
                    return;
                }

                searchTimer = setTimeout(function () {
                    searchProducts(query);
                }, 300);
            });

            document.addEventListener('click', function (e) {
                if (searchResults && !searchResults.contains(e.target) && e.target !== searchInput) {
                    hideResults();
                }
            });
        }

        if (assignBtn) {
            assignBtn.addEventListener('click', function () {
                assignSelectedProducts();
            });
        }

        if (assignedContainer) {
            assignedContainer.addEventListener('click', function (e) {
                var removeBtn = e.target.closest('.cf-remove-product');
                if (removeBtn) {
                    var idProduct = parseInt(removeBtn.getAttribute('data-id-product'));
                    removeProduct(idProduct, removeBtn.closest('.cf-assigned-product'));
                }
            });
        }
    }

    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        setTimeout(init, 100);
    } else {
        document.addEventListener('DOMContentLoaded', function () {
            setTimeout(init, 100);
        });
    }

    window.addEventListener('load', function () {
        if (!document.getElementById('flag_name')) return;
    });
})();
