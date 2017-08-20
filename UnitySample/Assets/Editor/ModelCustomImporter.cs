using System;
using UnityEngine;
using UnityEditor;

class ModelCustomImporter : AssetPostprocessor
{
    public void OnPostprocessModel(GameObject model)
    {
        Renderer[] renders = model.GetComponentsInChildren<Renderer>();
        if (null != renders)
        {
            foreach (Renderer render in renders)
            {
                render.sharedMaterials = new Material[render.sharedMaterials.Length];
            }
        }
    }

    public void OnPreprocessModel()
    {
        ModelImporter importer = assetImporter as ModelImporter;
        Debug.Log("___________________Name:" + importer.assetPath);
    }
}
