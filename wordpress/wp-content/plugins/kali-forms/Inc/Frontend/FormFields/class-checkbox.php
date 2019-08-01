<?php
namespace KaliForms\Inc\Frontend\FormFields;

if (!defined('ABSPATH')) {
    exit;
}

/**
 * Class Checkbox
 *
 * @package Inc\Frontend\FormFields;
 */
class Checkbox extends Form_Field
{
    /**
     * Class constructor
     */
    public function __construct()
    {
        $this->id = 'checkbox';
    }

    /**
     * Render function
     *
     * @return void
     */
    public function render($item, $form_info)
    {
        $item['type'] = 'checkbox';
        $div = '<div class="col-12 col-md-' . absint($item['col']) . '">';
        $div .= '<span style="margin-bottom:15px;display:inline-block">' . esc_html($item['caption']) . '</span>';
        $div .= $item['flow'] === 'vertical'
        ? $this->flow_vertical($item)
        : $this->flow_horizontal($item);
        $div .= !empty($item['description']) ? '<small>' . esc_html($item['description']) . '</small>' : '';
        $div .= '</div>';
        return $div;
    }
    /**
     * Flow vertical
     *
     * @param [type] $item
     * @param [type] $choice
     * @param [type] $i
     * @return void
     */
    public function flow_vertical($item)
    {
        $i = 0;
        $div = '';
        foreach ($item['choices'] as $choice) {
            $temp = $item['id'];
            $item['id'] = $item['id'] . $i;
            $attributes = $this->generate_attribute_string($item);
            $defaultValue = $this->default_value($item, $item['default']);

            is_array($defaultValue)
            ? $checked = in_array($choice->value, $defaultValue) ? 'checked' : ''
            : $checked = $choice->value === $defaultValue ? 'checked' : '';

            $div .= '<label>';
            $div .= '<input ' . $attributes . ' ' . $checked . ' value="' . esc_attr($choice->value) . '">' . esc_html($choice->label);
            $div .= '</label>';
            $item['id'] = $temp;

            $i++;
        }

        return $div;
    }
    /**
     * Flow horizontal
     *
     * @param [type] $item
     * @param [type] $choice
     * @param [type] $i
     * @return void
     */
    public function flow_horizontal($item)
    {
        $i = 0;
        $div = '<div class="row">';
        foreach ($item['choices'] as $choice) {
            $temp = $item['id'];
            $item['id'] = $item['id'] . $i;
            $attributes = $this->generate_attribute_string($item);
            $defaultValue = $this->default_value($item, $item['default']);
            is_array($defaultValue)
            ? $checked = in_array($choice->value, $defaultValue) ? 'checked' : ''
            : $checked = $choice->value === $defaultValue ? 'checked' : '';

            $div .= '<div class="col-12 col-md-4">';
            $div .= '<label>';
            $div .= '<input ' . $attributes . ' ' . $checked . ' value="' . esc_attr($choice->value) . '">' . esc_html($choice->label);
            $div .= '</label>';
            $div .= '</div>';
            $item['id'] = $temp;
            $i++;
        }
        $div .= '</div>';

        return $div;

    }
}
