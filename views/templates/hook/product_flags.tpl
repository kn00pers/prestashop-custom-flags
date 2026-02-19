{**
 * Custom Flags module for PrestaShop 8+
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the MIT License
 * that is bundled with this package in the file LICENSE.md.
 * It is also available through the world-wide-web at this URL:
 * https://opensource.org/licenses/MIT
 *
 * @author    Astrodesign.pl - github.com/kn00pers
 * @copyright Since 2026 Astrodesign.pl
 * @license   https://opensource.org/licenses/MIT MIT License
 *}

{if $custom_flags && $custom_flags|count > 0}
    <div class="custom-flags custom-flags-{$custom_flags_position|escape:'htmlall':'UTF-8'}"
         data-flags-position="{$custom_flags_position|escape:'htmlall':'UTF-8'}"
         data-product-id="{$custom_flags_product_id|intval}">
        {foreach from=$custom_flags item=flag}
            <span class="custom-flag"
                  style="background-color: {$flag.bg_color|escape:'htmlall':'UTF-8'}; color: {$flag.text_color|escape:'htmlall':'UTF-8'};"
                  title="{$flag.name|escape:'htmlall':'UTF-8'}">
                {$flag.name|escape:'htmlall':'UTF-8'}
            </span>
        {/foreach}
    </div>

    <script type="text/javascript">
    setTimeout(function() {
        var flagEl = document.querySelector('.custom-flags[data-product-id="{$custom_flags_product_id|intval}"]:not(.cf-done)');
        if (!flagEl) return;
        flagEl.classList.add('cf-done');

        var position = flagEl.getAttribute('data-flags-position');

        if (position === 'list') {
            var parent = flagEl.parentElement;
            var miniature = null;
            while (parent) {
                if (parent.classList && (
                    parent.classList.contains('js-product-miniature') ||
                    parent.classList.contains('product-miniature') ||
                    parent.tagName === 'ARTICLE'
                )) {
                    miniature = parent;
                    break;
                }
                parent = parent.parentElement;
            }

            if (miniature) {
                var thumb = miniature.querySelector('.thumbnail-top');
                if (!thumb) thumb = miniature.querySelector('.thumbnail-container');
                if (thumb) {
                    thumb.style.position = 'relative';
                    thumb.appendChild(flagEl);
                    flagEl.classList.add('cf-positioned');
                }

                var natives = miniature.querySelectorAll('ul.product-flags, ul.js-product-flags, .product-flag, .discount-product');
                for (var i = 0; i < natives.length; i++) {
                    natives[i].style.display = 'none';
                }
            }

        } else if (position === 'detail') {
            var cover = document.querySelector('.product-cover, .images-container');
            if (cover) {
                cover.style.position = 'relative';
                cover.appendChild(flagEl);
                flagEl.classList.add('cf-positioned');
            }
            var natives = document.querySelectorAll('ul.product-flags, ul.js-product-flags, .page-content > .product-flags, .product-flag:not(.custom-flag)');
            for (var i = 0; i < natives.length; i++) {
                natives[i].style.display = 'none';
            }
        }
    }, 0);
    </script>
{/if}
