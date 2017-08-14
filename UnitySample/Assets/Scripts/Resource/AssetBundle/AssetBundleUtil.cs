using System.Runtime.Remoting.Metadata;
using System.Text;
using UnityEngine;

// AssetPath : 相对Asset文件的相对路径， 可能带有后缀,如："MyTextures/hello.png"
// FullPath  : 全路径,可能带有后缀
// ProjectPath:相对工程资源的路径,比如："Assets/MyTextures/hello.png"

namespace  AssetBundles
{
    public class AssetBundleUtil
    {
        /// <summary>
        /// 编辑下如果AssetBundle 为非平台类型，物体可能显示为粉红色
        /// </summary>
        public static void ResetShaderInEditor<T>(T res)
        {
#if UNITY_EDITOR
            if (res != null && typeof(T) == typeof(GameObject))
            {
                Renderer[] Renders = (res as GameObject).GetComponentsInChildren<Renderer>();
                for (int i = 0; i < Renders.Length; i++)
                {
                    Material[] materials = Renders[i].sharedMaterials;
                    for (int j = 0; j < materials.Length; j++)
                    {
                        if (materials[j] != null && materials[j].shader != null)
                        {
                            materials[j].shader = Shader.Find(materials[j].shader.name);
                        }
                    }
                }
            }
#endif
        }

        public static string GetBundleName(string srcPath)
        {
            if (string.IsNullOrEmpty(srcPath))
            {
                Debug.LogError("AssetBundleUtil.GetBundleName: Input is null");
                return null;
            }

            srcPath = ToAssetPath(srcPath);
            srcPath = srcPath.ToLower();

            string bundleName = srcPath.Replace("/", "_");
            if (bundleName.LastIndexOf(".") >= 0)
            {
                bundleName = bundleName.Substring(0, bundleName.LastIndexOf("."));
            }
            return bundleName + AssetBundleConfig.ConstAssetTail;
        }

        public static string Normarlize(string s)
        {
            return s.Replace("\\", "/");
        }

        public static string ToFullPath(string srcPath)
        {
            if (string.IsNullOrEmpty(srcPath))
            {
                return string.Empty;
            }

            if (srcPath.Contains(Application.dataPath))
            {
                return srcPath;
            }

            if (srcPath.Contains("Assets"))
            {
                srcPath = srcPath.Substring("Assets".Length + 1);
            }

            srcPath = Application.dataPath + "/" + srcPath;
            return Normarlize(srcPath);
        }

        public static string ToAssetPath(string fullPath)
        {
            string path = ToProjectPath(fullPath);
            if (string.IsNullOrEmpty(path))
            {
                return string.Empty;
            }

            if (path.Contains("Assets"))
            {
                path = path.Substring("Assets".Length + 1);
            }

            return Normarlize(path);
        }

        public static string ToProjectPath(string fullPath)
        {
            if (string.IsNullOrEmpty(fullPath))
            {
                return string.Empty;
            }

            if (fullPath.Contains(Application.dataPath))
            {
                fullPath = fullPath.Substring(Application.dataPath.Length);
            }
            else
            {
                return fullPath;
            }

            return Normarlize("Assets" + fullPath);
        }
    }
}