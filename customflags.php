<?php
//Astrodesign.pl - github.com/kn00pers
//2026
//Do whatever you want with this module - just don't sell it

if (!defined('_PS_VERSION_')) {
    exit;
}

class CustomFlags extends Module
{
    public function __construct()
    {
        $this->name = 'customflags';
        $this->tab = 'front_office_features';
        $this->version = '1.2.0';
        $this->author = 'Astrodesign.pl';
        $this->need_instance = 0;
        $this->ps_versions_compliancy = ['min' => '8.0.0', 'max' => _PS_VERSION_];
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->l('Custom Flags');
        $this->description = $this->l('Add custom flags/labels to your products.');
        $this->confirmUninstall = $this->l('Are you sure you want to uninstall Custom Flags? All flag data will be lost.');
    }

    public function install()
    {
        return parent::install()
            && $this->createTables()
            && $this->migrateToLang()
            && $this->registerHook('displayProductListReviews')
            && $this->registerHook('displayProductAdditionalInfo')
            && $this->registerHook('actionFrontControllerSetMedia')
            && $this->installTab();
    }

    public function uninstall()
    {
        return parent::uninstall()
            && $this->dropTables()
            && $this->uninstallTab();
    }

    private function createTables()
    {
        $sql = [];

        $sql[] = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'custom_flag` (
            `id_custom_flag` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
            `bg_color` VARCHAR(7) NOT NULL DEFAULT \'#FF5722\',
            `text_color` VARCHAR(7) NOT NULL DEFAULT \'#FFFFFF\',
            `position` INT(11) UNSIGNED NOT NULL DEFAULT 0,
            `active` TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
            `date_add` DATETIME NOT NULL,
            `date_upd` DATETIME NOT NULL,
            PRIMARY KEY (`id_custom_flag`)
        ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

        $sql[] = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'custom_flag_lang` (
            `id_custom_flag` INT(11) UNSIGNED NOT NULL,
            `id_lang` INT(11) UNSIGNED NOT NULL,
            `name` VARCHAR(128) NOT NULL,
            PRIMARY KEY (`id_custom_flag`, `id_lang`)
        ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

        $sql[] = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'custom_flag_product` (
            `id_custom_flag` INT(11) UNSIGNED NOT NULL,
            `id_product` INT(11) UNSIGNED NOT NULL,
            PRIMARY KEY (`id_custom_flag`, `id_product`),
            KEY `idx_product` (`id_product`)
        ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

        foreach ($sql as $query) {
            if (!Db::getInstance()->execute($query)) {
                return false;
            }
        }

        return true;
    }

    private function migrateToLang()
    {
        $db = Db::getInstance();


        $columns = $db->executeS('SHOW COLUMNS FROM `' . _DB_PREFIX_ . 'custom_flag` LIKE \'name\'');

        if (!empty($columns)) {

            $flags = $db->executeS('SELECT `id_custom_flag`, `name` FROM `' . _DB_PREFIX_ . 'custom_flag`');

            if ($flags) {
                $languages = Language::getLanguages(false);

                foreach ($flags as $flag) {
                    foreach ($languages as $lang) {
                        $exists = (int) $db->getValue(
                            'SELECT COUNT(*) FROM `' . _DB_PREFIX_ . 'custom_flag_lang`
                             WHERE `id_custom_flag` = ' . (int) $flag['id_custom_flag'] . '
                               AND `id_lang` = ' . (int) $lang['id_lang']
                        );

                        if (!$exists) {
                            $db->insert('custom_flag_lang', [
                                'id_custom_flag' => (int) $flag['id_custom_flag'],
                                'id_lang' => (int) $lang['id_lang'],
                                'name' => pSQL($flag['name']),
                            ]);
                        }
                    }
                }
            }


            $db->execute('ALTER TABLE `' . _DB_PREFIX_ . 'custom_flag` DROP COLUMN `name`');
        }

        return true;
    }

    private function dropTables()
    {
        $sql = [];
        $sql[] = 'DROP TABLE IF EXISTS `' . _DB_PREFIX_ . 'custom_flag_product`';
        $sql[] = 'DROP TABLE IF EXISTS `' . _DB_PREFIX_ . 'custom_flag_lang`';
        $sql[] = 'DROP TABLE IF EXISTS `' . _DB_PREFIX_ . 'custom_flag`';

        foreach ($sql as $query) {
            if (!Db::getInstance()->execute($query)) {
                return false;
            }
        }

        return true;
    }

    private function installTab()
    {
        $tab = new Tab();
        $tab->active = 1;
        $tab->class_name = 'AdminCustomFlags';
        $tab->route_name = '';
        $tab->name = [];

        foreach (Language::getLanguages(true) as $lang) {
            $tab->name[$lang['id_lang']] = 'Custom Flags';
        }

        $tab->id_parent = (int) Tab::getIdFromClassName('AdminCatalog');
        $tab->module = $this->name;

        return $tab->add();
    }

    private function uninstallTab()
    {
        $idTab = (int) Tab::getIdFromClassName('AdminCustomFlags');
        if ($idTab) {
            $tab = new Tab($idTab);
            return $tab->delete();
        }

        return true;
    }

    public static function getFlagsByProduct($idProduct)
    {
        $idLang = (int) Context::getContext()->language->id;

        $sql = 'SELECT cf.*, cfl.`name`
                FROM `' . _DB_PREFIX_ . 'custom_flag` cf
                INNER JOIN `' . _DB_PREFIX_ . 'custom_flag_lang` cfl
                    ON cfl.`id_custom_flag` = cf.`id_custom_flag`
                    AND cfl.`id_lang` = ' . $idLang . '
                INNER JOIN `' . _DB_PREFIX_ . 'custom_flag_product` cfp
                    ON cf.`id_custom_flag` = cfp.`id_custom_flag`
                WHERE cfp.`id_product` = ' . (int) $idProduct . '
                    AND cf.`active` = 1
                ORDER BY cf.`position` ASC, cfl.`name` ASC';

        return Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS($sql);
    }

    public function hookDisplayProductListReviews($params)
    {
        if (!isset($params['product']['id_product'])) {
            return '';
        }

        $idProduct = (int) $params['product']['id_product'];
        $flags = self::getFlagsByProduct($idProduct);

        if (empty($flags)) {
            return '';
        }

        $this->context->smarty->assign([
            'custom_flags' => $flags,
            'custom_flags_position' => 'list',
            'custom_flags_product_id' => $idProduct,
        ]);

        return $this->display(__FILE__, 'views/templates/hook/product_flags.tpl');
    }

    public function hookDisplayProductAdditionalInfo($params)
    {
        if (!isset($params['product']['id_product'])) {
            if (isset($params['product']) && is_object($params['product'])) {
                $idProduct = (int) $params['product']->id;
            } else {
                return '';
            }
        } else {
            $idProduct = (int) $params['product']['id_product'];
        }

        $flags = self::getFlagsByProduct($idProduct);

        if (empty($flags)) {
            return '';
        }

        $this->context->smarty->assign([
            'custom_flags' => $flags,
            'custom_flags_position' => 'detail',
            'custom_flags_product_id' => $idProduct,
        ]);

        return $this->display(__FILE__, 'views/templates/hook/product_flags.tpl');
    }

    public function hookActionFrontControllerSetMedia()
    {
        $this->context->controller->registerStylesheet(
            'customflags-front',
            'modules/' . $this->name . '/views/css/front.css',
            ['media' => 'all', 'priority' => 150]
        );
    }
}
