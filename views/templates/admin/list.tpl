

<div class="panel">
    <div class="panel-heading">
        <i class="icon-flag"></i> {l s='Custom Flags' mod='customflags'}
        <span class="badge">{$flags|count}</span>
        <span class="panel-heading-action">
            <a class="list-toolbar-btn" href="{$add_flag_url|escape:'htmlall':'UTF-8'}">
                <span title="{l s='Add new flag' mod='customflags'}" class="label-tooltip" data-toggle="tooltip" data-html="true">
                    <i class="process-icon-new"></i>
                </span>
            </a>
        </span>
    </div>

    {if $flags|count > 0}
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th class="text-center" style="width: 50px;">ID</th>
                        <th>{l s='Name' mod='customflags'}</th>
                        <th class="text-center">{l s='Preview' mod='customflags'}</th>
                        <th class="text-center" style="width: 100px;">{l s='Products' mod='customflags'}</th>
                        <th class="text-center" style="width: 80px;">{l s='Position' mod='customflags'}</th>
                        <th class="text-center" style="width: 80px;">{l s='Active' mod='customflags'}</th>
                        <th class="text-center" style="width: 120px;">{l s='Actions' mod='customflags'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$flags item=flag}
                        <tr>
                            <td class="text-center">{$flag.id_custom_flag|intval}</td>
                            <td><strong>{$flag.name|escape:'htmlall':'UTF-8'}</strong></td>
                            <td class="text-center">
                                <span class="custom-flag-preview" style="
                                    background-color: {$flag.bg_color|escape:'htmlall':'UTF-8'};
                                    color: {$flag.text_color|escape:'htmlall':'UTF-8'};
                                    padding: 4px 12px;
                                    border-radius: 3px;
                                    font-size: 12px;
                                    font-weight: 600;
                                    display: inline-block;
                                ">
                                    {$flag.name|escape:'htmlall':'UTF-8'}
                                </span>
                            </td>
                            <td class="text-center">
                                <span class="badge">{$flag.product_count|intval}</span>
                            </td>
                            <td class="text-center">{$flag.position|intval}</td>
                            <td class="text-center">
                                <a href="{$current_url|escape:'htmlall':'UTF-8'}&toggleActive=1&id_custom_flag={$flag.id_custom_flag|intval}"
                                   title="{l s='Toggle active' mod='customflags'}">
                                    {if $flag.active}
                                        <i class="icon-check text-success" style="font-size: 18px;"></i>
                                    {else}
                                        <i class="icon-remove text-danger" style="font-size: 18px;"></i>
                                    {/if}
                                </a>
                            </td>
                            <td class="text-center">
                                <div class="btn-group-action">
                                    <div class="btn-group pull-right">
                                        <a class="btn btn-default"
                                           href="{$current_url|escape:'htmlall':'UTF-8'}&action=editFlag&id_custom_flag={$flag.id_custom_flag|intval}"
                                           title="{l s='Edit' mod='customflags'}">
                                            <i class="icon-pencil"></i> {l s='Edit' mod='customflags'}
                                        </a>
                                        <button class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                                            <span class="caret"></span>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li>
                                                <a href="{$current_url|escape:'htmlall':'UTF-8'}&deleteFlag=1&id_custom_flag={$flag.id_custom_flag|intval}"
                                                   onclick="return confirm('{l s='Are you sure you want to delete this flag?' mod='customflags'}');"
                                                   title="{l s='Delete' mod='customflags'}">
                                                    <i class="icon-trash"></i> {l s='Delete' mod='customflags'}
                                                </a>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    {else}
        <div class="alert alert-info">
            <p>{l s='No custom flags created yet. Click the "+" button to create your first flag.' mod='customflags'}</p>
        </div>
    {/if}
</div>
