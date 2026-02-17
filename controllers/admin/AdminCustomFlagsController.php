<?php

if (!defined('_PS_VERSION_')) {
    exit;
}

class AdminCustomFlagsController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true;
        $this->table = 'custom_flag';
        $this->identifier = 'id_custom_flag';
        $this->className = 'ObjectModel';
        $this->lang = false;
        $this->_defaultOrderBy = 'position';
        $this->_defaultOrderWay = 'ASC';
        $this->allow_export = false;

        parent::__construct();

        $this->meta_title = $this->l('Custom Flags');
    }

    public function setMedia($isNewTheme = false)
    {
        parent::setMedia($isNewTheme);

        $this->addCSS($this->module->getPathUri() . 'views/css/admin.css');
    }

    public function initContent()
    {
        parent::initContent();

        $action = Tools::getValue('action');

        if ($action === 'addFlag' || $action === 'editFlag') {
            $this->renderFlagForm();
        } else {
            $this->renderFlagList();
        }
    }

    private function renderFlagList()
    {
        $flags = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
            'SELECT * FROM `' . _DB_PREFIX_ . 'custom_flag` ORDER BY `position` ASC, `name` ASC'
        );

        if ($flags) {
            foreach ($flags as &$flag) {
                $flag['product_count'] = (int) Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
                    'SELECT COUNT(*) FROM `' . _DB_PREFIX_ . 'custom_flag_product`
                     WHERE `id_custom_flag` = ' . (int) $flag['id_custom_flag']
                );
            }
        }

        $this->context->smarty->assign([
            'flags' => $flags ?: [],
            'add_flag_url' => $this->context->link->getAdminLink('AdminCustomFlags') . '&action=addFlag',
            'current_url' => $this->context->link->getAdminLink('AdminCustomFlags'),
        ]);

        $this->context->smarty->assign('content', $this->context->smarty->fetch(
            _PS_MODULE_DIR_ . 'customflags/views/templates/admin/list.tpl'
        ));
    }

    private function renderFlagForm()
    {
        $idFlag = (int) Tools::getValue('id_custom_flag', 0);
        $flag = null;
        $assignedProducts = [];

        if ($idFlag > 0) {
            $flag = Db::getInstance(_PS_USE_SQL_SLAVE_)->getRow(
                'SELECT * FROM `' . _DB_PREFIX_ . 'custom_flag`
                 WHERE `id_custom_flag` = ' . $idFlag
            );

            $assignedProducts = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
                'SELECT p.`id_product`, pl.`name`, p.`reference`, i.`id_image`
                 FROM `' . _DB_PREFIX_ . 'custom_flag_product` cfp
                 INNER JOIN `' . _DB_PREFIX_ . 'product` p ON p.`id_product` = cfp.`id_product`
                 INNER JOIN `' . _DB_PREFIX_ . 'product_lang` pl
                    ON pl.`id_product` = p.`id_product`
                    AND pl.`id_lang` = ' . (int) $this->context->language->id . '
                    AND pl.`id_shop` = ' . (int) $this->context->shop->id . '
                 LEFT JOIN `' . _DB_PREFIX_ . 'image` i
                    ON i.`id_product` = p.`id_product` AND i.`cover` = 1
                 WHERE cfp.`id_custom_flag` = ' . $idFlag . '
                 ORDER BY pl.`name` ASC'
            );

            if ($assignedProducts) {
                foreach ($assignedProducts as &$product) {
                    if ($product['id_image']) {
                        $product['image_url'] = $this->context->link->getImageLink(
                            $product['name'],
                            $product['id_image'],
                            'small_default'
                        );
                    } else {
                        $product['image_url'] = '';
                    }
                }
            }
        }

        $this->context->smarty->assign([
            'flag' => $flag,
            'assigned_products' => $assignedProducts ?: [],
            'id_custom_flag' => $idFlag,
            'ajax_url' => $this->context->link->getAdminLink('AdminCustomFlags'),
            'list_url' => $this->context->link->getAdminLink('AdminCustomFlags'),
            'admin_token' => Tools::getAdminTokenLite('AdminCustomFlags'),
        ]);

        $this->context->smarty->assign('content', $this->context->smarty->fetch(
            _PS_MODULE_DIR_ . 'customflags/views/templates/admin/form.tpl'
        ));
    }

    public function postProcess()
    {
        if (Tools::isSubmit('submitSaveFlag')) {
            $this->processSaveFlag();
        }

        if (Tools::isSubmit('deleteFlag')) {
            $this->processDeleteFlag();
        }

        if (Tools::isSubmit('toggleActive')) {
            $this->processToggleActive();
        }

        parent::postProcess();
    }

    private function processSaveFlag()
    {
        $idFlag = (int) Tools::getValue('id_custom_flag', 0);
        $name = pSQL(Tools::getValue('flag_name', ''));
        $bgColor = pSQL(Tools::getValue('bg_color', '#FF5722'));
        $textColor = pSQL(Tools::getValue('text_color', '#FFFFFF'));
        $position = (int) Tools::getValue('position', 0);
        $active = (int) Tools::getValue('active', 1);

        if (empty($name)) {
            $this->errors[] = $this->l('Flag name is required.');
            return;
        }

        $now = date('Y-m-d H:i:s');

        if ($idFlag > 0) {
            $result = Db::getInstance()->update('custom_flag', [
                'name' => $name,
                'bg_color' => $bgColor,
                'text_color' => $textColor,
                'position' => $position,
                'active' => $active,
                'date_upd' => $now,
            ], 'id_custom_flag = ' . $idFlag);

            if ($result) {
                $this->confirmations[] = $this->l('Flag updated successfully.');
                Tools::redirectAdmin($this->context->link->getAdminLink('AdminCustomFlags') . '&action=editFlag&id_custom_flag=' . $idFlag . '&conf=4');
            }
        } else {
            $result = Db::getInstance()->insert('custom_flag', [
                'name' => $name,
                'bg_color' => $bgColor,
                'text_color' => $textColor,
                'position' => $position,
                'active' => $active,
                'date_add' => $now,
                'date_upd' => $now,
            ]);

            if ($result) {
                $newId = (int) Db::getInstance()->Insert_ID();
                $this->confirmations[] = $this->l('Flag created successfully.');
                Tools::redirectAdmin($this->context->link->getAdminLink('AdminCustomFlags') . '&action=editFlag&id_custom_flag=' . $newId . '&conf=3');
            }
        }
    }

    private function processDeleteFlag()
    {
        $idFlag = (int) Tools::getValue('id_custom_flag', 0);

        if ($idFlag > 0) {
            Db::getInstance()->delete('custom_flag_product', 'id_custom_flag = ' . $idFlag);
            Db::getInstance()->delete('custom_flag', 'id_custom_flag = ' . $idFlag);
            $this->confirmations[] = $this->l('Flag deleted successfully.');
            Tools::redirectAdmin($this->context->link->getAdminLink('AdminCustomFlags') . '&conf=1');
        }
    }

    private function processToggleActive()
    {
        $idFlag = (int) Tools::getValue('id_custom_flag', 0);

        if ($idFlag > 0) {
            $current = (int) Db::getInstance()->getValue(
                'SELECT `active` FROM `' . _DB_PREFIX_ . 'custom_flag` WHERE `id_custom_flag` = ' . $idFlag
            );

            Db::getInstance()->update('custom_flag', [
                'active' => $current ? 0 : 1,
                'date_upd' => date('Y-m-d H:i:s'),
            ], 'id_custom_flag = ' . $idFlag);

            Tools::redirectAdmin($this->context->link->getAdminLink('AdminCustomFlags') . '&conf=5');
        }
    }

    public function ajaxProcessSearchProducts()
    {
        $query = pSQL(Tools::getValue('q', ''));
        $idFlag = (int) Tools::getValue('id_custom_flag', 0);

        if (Tools::strlen($query) < 2) {
            $this->ajaxDie(json_encode(['products' => []]));
            return;
        }

        $idLang = (int) $this->context->language->id;
        $idShop = (int) $this->context->shop->id;

        $sql = 'SELECT p.`id_product`, pl.`name`, p.`reference`, i.`id_image`
                FROM `' . _DB_PREFIX_ . 'product` p
                INNER JOIN `' . _DB_PREFIX_ . 'product_shop` ps
                    ON ps.`id_product` = p.`id_product`
                    AND ps.`id_shop` = ' . $idShop . '
                INNER JOIN `' . _DB_PREFIX_ . 'product_lang` pl
                    ON pl.`id_product` = p.`id_product`
                    AND pl.`id_lang` = ' . $idLang . '
                    AND pl.`id_shop` = ' . $idShop . '
                LEFT JOIN `' . _DB_PREFIX_ . 'image_shop` ish
                    ON ish.`id_product` = p.`id_product`
                    AND ish.`id_shop` = ' . $idShop . '
                    AND ish.`cover` = 1
                LEFT JOIN `' . _DB_PREFIX_ . 'image` i
                    ON i.`id_image` = ish.`id_image`';

        if ($idFlag > 0) {
            $sql .= ' LEFT JOIN `' . _DB_PREFIX_ . 'custom_flag_product` cfp
                        ON cfp.`id_product` = p.`id_product`
                        AND cfp.`id_custom_flag` = ' . $idFlag;
            $sql .= ' WHERE cfp.`id_product` IS NULL AND ';
        } else {
            $sql .= ' WHERE ';
        }

        $sql .= '(pl.`name` LIKE \'%' . $query . '%\' OR p.`reference` LIKE \'%' . $query . '%\')
                 GROUP BY p.`id_product`
                 ORDER BY pl.`name` ASC
                 LIMIT 30';

        $products = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS($sql);

        if ($products) {
            foreach ($products as &$product) {
                if ($product['id_image']) {
                    $product['image_url'] = $this->context->link->getImageLink(
                        $product['name'],
                        $product['id_product'] . '-' . $product['id_image'],
                        'small_default'
                    );
                } else {
                    $product['image_url'] = '';
                }
            }
        }

        header('Content-Type: application/json');
        $this->ajaxDie(json_encode(['products' => $products ?: []]));
    }

    public function ajaxProcessAssignProducts()
    {
        $idFlag = (int) Tools::getValue('id_custom_flag', 0);
        $productIds = Tools::getValue('product_ids', []);

        if ($idFlag <= 0 || empty($productIds)) {
            header('Content-Type: application/json');
            $this->ajaxDie(json_encode(['success' => false, 'error' => 'Invalid parameters']));
            return;
        }

        if (!is_array($productIds)) {
            $productIds = explode(',', $productIds);
        }

        $added = 0;
        foreach ($productIds as $idProduct) {
            $idProduct = (int) $idProduct;
            if ($idProduct <= 0) {
                continue;
            }

            $exists = Db::getInstance()->getValue(
                'SELECT COUNT(*) FROM `' . _DB_PREFIX_ . 'custom_flag_product`
                 WHERE `id_custom_flag` = ' . $idFlag . ' AND `id_product` = ' . $idProduct
            );

            if (!$exists) {
                Db::getInstance()->insert('custom_flag_product', [
                    'id_custom_flag' => $idFlag,
                    'id_product' => $idProduct,
                ]);
                $added++;
            }
        }

        $assignedProducts = $this->getAssignedProductsData($idFlag);

        header('Content-Type: application/json');
        $this->ajaxDie(json_encode([
            'success' => true,
            'added' => $added,
            'assigned_products' => $assignedProducts,
        ]));
    }

    public function ajaxProcessRemoveProduct()
    {
        $idFlag = (int) Tools::getValue('id_custom_flag', 0);
        $idProduct = (int) Tools::getValue('id_product', 0);

        if ($idFlag <= 0 || $idProduct <= 0) {
            header('Content-Type: application/json');
            $this->ajaxDie(json_encode(['success' => false, 'error' => 'Invalid parameters']));
            return;
        }

        Db::getInstance()->delete(
            'custom_flag_product',
            'id_custom_flag = ' . $idFlag . ' AND id_product = ' . $idProduct
        );

        header('Content-Type: application/json');
        $this->ajaxDie(json_encode(['success' => true]));
    }

    private function getAssignedProductsData($idFlag)
    {
        $idShop = (int) $this->context->shop->id;

        $products = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
            'SELECT p.`id_product`, pl.`name`, p.`reference`, i.`id_image`
             FROM `' . _DB_PREFIX_ . 'custom_flag_product` cfp
             INNER JOIN `' . _DB_PREFIX_ . 'product` p ON p.`id_product` = cfp.`id_product`
             INNER JOIN `' . _DB_PREFIX_ . 'product_lang` pl
                ON pl.`id_product` = p.`id_product`
                AND pl.`id_lang` = ' . (int) $this->context->language->id . '
                AND pl.`id_shop` = ' . $idShop . '
             LEFT JOIN `' . _DB_PREFIX_ . 'image_shop` ish
                ON ish.`id_product` = p.`id_product`
                AND ish.`id_shop` = ' . $idShop . '
                AND ish.`cover` = 1
             LEFT JOIN `' . _DB_PREFIX_ . 'image` i
                ON i.`id_image` = ish.`id_image`
             WHERE cfp.`id_custom_flag` = ' . (int) $idFlag . '
             GROUP BY p.`id_product`
             ORDER BY pl.`name` ASC'
        );

        if ($products) {
            foreach ($products as &$product) {
                if ($product['id_image']) {
                    $product['image_url'] = $this->context->link->getImageLink(
                        $product['name'],
                        $product['id_product'] . '-' . $product['id_image'],
                        'small_default'
                    );
                } else {
                    $product['image_url'] = '';
                }
            }
        }

        return $products ?: [];
    }
}
