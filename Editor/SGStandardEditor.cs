using UnityEngine;
using System.Collections;
using UnityEditor;

public class SGStandardEditor : ShaderGUI
{
    MaterialProperty main_tex_;
    MaterialProperty coudiness_;
    MaterialProperty front_tex_;
    MaterialProperty front_tex_power_;
    MaterialProperty normal_tex_;
    MaterialProperty mask_width_;
    MaterialProperty mask_height_;
    MaterialProperty glossiness_;
    MaterialProperty metallic_;

    public override void OnGUI(MaterialEditor editor, MaterialProperty[] props)
    {
        Material material = editor.target as Material;

        main_tex_ = FindProperty("_MainTex", props, false);
        coudiness_ = FindProperty("_Cloudiness", props, false);
        front_tex_ = FindProperty("_FrontTex", props, false);
        front_tex_power_ = FindProperty("_FrontTexPower", props, false);
        normal_tex_ = FindProperty("_NormalTex", props, false);
        mask_width_ = FindProperty("_MaskWidth", props, false);
        mask_height_ = FindProperty("_MaskHeight", props, false);
        glossiness_ = FindProperty("_Glossiness", props, false);
        metallic_ = FindProperty("_Metallic", props, false);

        EditorGUIUtility.labelWidth = 0f;
        EditorGUI.BeginChangeCheck();

        if (GUILayout.Button("Show docs / 取扱説明書を表示"))
        {
            System.Diagnostics.Process.Start("https://azuritelab.github.io/VRCSmokeGlassDocs/");
        }

        editor.ShaderProperty(main_tex_, "Smoke Texture(Specified)");
        editor.ShaderProperty(front_tex_, "Texture");
        editor.ShaderProperty(front_tex_power_, "Texture Power");
        editor.ShaderProperty(normal_tex_, "Normal");
        editor.ShaderProperty(coudiness_, "Cloudiness");

        EditorGUILayout.LabelField("Mask Settings", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        editor.ShaderProperty(mask_width_, "Width");
        editor.ShaderProperty(mask_height_, "Height");
        EditorGUI.indentLevel--;

        EditorGUILayout.LabelField("Standard Properties", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        editor.ShaderProperty(glossiness_, "Glossiness");
        editor.ShaderProperty(metallic_, "Metallic");
        EditorGUI.indentLevel--;

        EditorGUI.EndChangeCheck();
    }
}