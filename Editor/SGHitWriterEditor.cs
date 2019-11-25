using UnityEngine;
using System.Collections;
using UnityEditor;

public class SGHitBufferWriterEditor : ShaderGUI
{
    MaterialProperty render_texture_;
    MaterialProperty tolerance_;
    MaterialProperty using_blur_;
    MaterialProperty reset_;
    MaterialProperty enable_restoration_;
    MaterialProperty restoration_resolution_;
    MaterialProperty restoration_speed_;
    MaterialProperty interpolation_type_;
    MaterialProperty hermite_left_point_;
    MaterialProperty hermite_right_point_;

    public override void OnGUI(MaterialEditor editor, MaterialProperty[] props)
    {
        Material material = editor.target as Material;

        render_texture_ = FindProperty("_tex", props, false);
        tolerance_ = FindProperty("_tolerance", props, false);
        using_blur_ = FindProperty("_using_blur", props, false);
        reset_ = FindProperty("_reset", props, false);
        enable_restoration_ = FindProperty("_enable_restoration", props, false);
        restoration_resolution_ = FindProperty("_restoration_resolution", props, false);
        restoration_speed_ = FindProperty("_restoration_speed", props, false);
        interpolation_type_ = FindProperty("_interpolate_type", props, false);
        hermite_left_point_ = FindProperty("_hermite_left_point", props, false);
        hermite_right_point_ = FindProperty("_hermite_right_point", props, false);

        EditorGUIUtility.labelWidth = 0f;
        EditorGUI.BeginChangeCheck();

        if (GUILayout.Button("Show docs / 取扱説明書を表示"))
        {
            System.Diagnostics.Process.Start("https://azuritelab.github.io/VRCSmokeGlassDocs/");
        }

        editor.ShaderProperty(render_texture_, "Render Texture");
        editor.ShaderProperty(tolerance_, "Tolerance");
        editor.ShaderProperty(using_blur_, "Using blur");
        editor.ShaderProperty(reset_, "Reset");

        editor.ShaderProperty(enable_restoration_, "Enable Restoration");
        float enable_restoration = enable_restoration_.floatValue;
        if (enable_restoration == 1.0)
        {
            EditorGUILayout.LabelField("Restoration Settings", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;

            editor.ShaderProperty(restoration_resolution_, "Resolution");
            editor.ShaderProperty(restoration_speed_, "Speed");
            editor.ShaderProperty(interpolation_type_, "Interpolation Type");
            float interpolation_type = interpolation_type_.floatValue;
            if (interpolation_type == 1.0)
            {
                EditorGUILayout.LabelField("Hermite Interpolation", EditorStyles.boldLabel);
                EditorGUI.indentLevel++;

                editor.ShaderProperty(hermite_left_point_, "Left Point");
                editor.ShaderProperty(hermite_right_point_, "Right Point");

                EditorGUI.indentLevel--;
            }

            EditorGUI.indentLevel--;
        }


        EditorGUI.EndChangeCheck();
    }
}