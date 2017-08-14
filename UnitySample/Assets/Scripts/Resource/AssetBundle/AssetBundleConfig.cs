using System.Collections.Generic;
using System.Linq;

using UnityEngine;

namespace AssetBundles
{
    /// <summary>
    /// 资源类型枚举
    /// </summary>
    public enum BundleType
    {
        //角色
        Character,
        //战斗 技能相机
        Camera,
        //战斗 地图配置
        Stage,
        //战斗 技能
        Cinematic,
        //战斗 portrait
        Portrait,

        //特效
        Effect,

        //Atlas
        UIAtlas,
        //单独图片
        UIIconAndRawImage,
        //UI
        Panel,

        //系统，包含Story\TakePicture\stLine
        Prefabs,
        //建筑
        Builder,

        //设置
        Settings,

        // 剧情声音
        StoryAudio,

        //A类剧情声音
        StoryAScene,
        //场景
        Scene,

        Max,
    }

    public class IgnoreTypeConfig
    {
        public BundleType BundleType;
        public string ConfigName;
        public string[] NamePostfixs;
    }

    public enum PackStrategy
    {
        Default, //每个文件单独打包
        One,     //全部文件打包到一个
    }

    public enum DependenciesStrategy
    {
        None,   //无依赖
        Direct, //直接依赖
        All,    //全部依赖
    }

    public class PackTargetConfig
    {
        public BundleType Type;                 //目标类型
        public string Name;                     //路径名
        public string[] AssetPath;              //路径(Asset目录下), 对每个路径下的文件处理策略相同
        public DependenciesStrategy Dependency; //依赖检测机制
        public PackStrategy PackStrategy;       // 打包策略
    }

    public static class AssetBundleConfig
    {
        //AssetBundle 资源 父目录
        public static readonly string AssetBundlesPath = "assetbundle";

        // AssetBundle 后缀
        public const string ConstAssetTail = ".unity3d";

        //Shader文件打包名字
        public const string ConstShaderAssetBundleName = "common_shader_asset" + ConstAssetTail;

        //异步加载超时设置(S)
        public const float ConstAsyncLoadAssetTimeLimit = 60f;
        public const float ConstAsyncLoadSceneTimeLimit = 120f;

        //打包资源配置
        private static readonly PackTargetConfig[] mPackTargetConfigs =
        {
            new PackTargetConfig
                        {
                            Type = BundleType.Character,
                            Name = "Character",
                            AssetPath =  new[]
                            {
//                                "Resources/avatar" ,              //自定义数据
//                                "Resources/charactercustom" ,     //自定义数据
                                "Resources/character",            //角色数据
                            },

                            Dependency = DependenciesStrategy.All ,
                            PackStrategy = PackStrategy.Default ,
                        },

            new PackTargetConfig
                        {
                            Type = BundleType.Camera,
                            Name = "Camera",
                            AssetPath =  new[]
                            {
                                "Resources/camera",
                                "Resources/scene/camera"
                            },

                            Dependency =  DependenciesStrategy.None ,
                            PackStrategy = PackStrategy.One ,
                        },

            new PackTargetConfig
                        {
                            Type = BundleType.Cinematic,
                            Name = "Cinematic",
                            AssetPath =  new[]
                            {
                                "Resources/Cinematic"
                            },
                            Dependency =  DependenciesStrategy.None ,
                            PackStrategy = PackStrategy.Default ,
                        },
            new PackTargetConfig
                        {
                            Type = BundleType.Stage,
                            Name = "Stage",
                            AssetPath =  new[]
                            {
                                "Resources/scene/stage"
                            },
                            Dependency =  DependenciesStrategy.None ,
                            PackStrategy = PackStrategy.One ,
                        },
            new PackTargetConfig
                        {
                            Type = BundleType.Portrait,
                            Name = "Portrait",
                            AssetPath =  new[]
                            {
                                "Resources/portrait"
                            },
                            Dependency =  DependenciesStrategy.All ,
                            PackStrategy = PackStrategy.Default ,
                        },
            new PackTargetConfig  
                        {
                            Type = BundleType.Effect,
                            Name = "Effect",
                            AssetPath =  new[]
                            {
                                "Resources/effect"
                            },
                            Dependency =  DependenciesStrategy.All ,
                            PackStrategy = PackStrategy.Default ,
                        },


            new PackTargetConfig
                        {
                            Type = BundleType.UIAtlas,
                            Name = "UIAtlas",
                            AssetPath = new[]
                            {
                                "UI/atlas/battle", //Atlas
                                "UI/atlas/common",
                                "UI/atlas/login",
                                "UI/atlas/main",

                                "UI/bitmap_font", //bitmap font
                                "UI/fonts",       //bitmap font
                            },
                            Dependency = DependenciesStrategy.None,
                            PackStrategy = PackStrategy.One,
                        },
            new PackTargetConfig
                        {
                            Type = BundleType.UIIconAndRawImage,
                            Name = "UIIconAndRawImage",
                            AssetPath = new[]
                            {
                                "Resources/ui/icon", 
                                "UI/rawimage",      // 图片设置需要为defaut类型，配合rawimage组件
                                "ArtSrc/font",      // Font
                            },
                            Dependency = DependenciesStrategy.None,
                            PackStrategy = PackStrategy.Default,
                        },

            new PackTargetConfig
                        {
                            Type = BundleType.Panel,
                            Name = "Panel",
                            AssetPath = new[]
                            {
                                "Resources/ui/panel",
                                "Resources/ui/template",
                            },
                            Dependency = DependenciesStrategy.All,
                            PackStrategy = PackStrategy.Default,
                        },

            new PackTargetConfig
                        {
                            Type = BundleType.Settings,
                            Name = "Setting",
                            AssetPath = new[]
                            {
                                "Resources/settings",
                            },
                            Dependency = DependenciesStrategy.None,
                            PackStrategy = PackStrategy.Default,
                        },

            new PackTargetConfig
                        {
                            Type = BundleType.Builder,
                            Name = "Builder",
                            AssetPath = new[]
                            { 
                                "Resources/scene/builder",
                            },
                            Dependency = DependenciesStrategy.All,
                            PackStrategy = PackStrategy.Default,
                        },

            new PackTargetConfig  
                        {
                            Type = BundleType.Prefabs,
                            Name = "Prefabs",
                            AssetPath = new[]
                            {
                                "Resources/prefabs",
                            },
                            Dependency = DependenciesStrategy.All,
                            PackStrategy = PackStrategy.Default,
                        },

            new PackTargetConfig
                        {
                            Type = BundleType.StoryAudio,
                            Name = "StoryAudio",
                            AssetPath = new[]
                            {
                                "Resources/StoryAudio/AClass",         
                                "Resources/StoryAudio/BClass",         
                            },
                            Dependency = DependenciesStrategy.None,
                            PackStrategy = PackStrategy.One,
                        },

            new PackTargetConfig
                        {
                            Type = BundleType.StoryAScene,
                            Name = "StoryAScene",
                            AssetPath = new[]
                            {
                                "Scenes/story_a",       //A 类剧情场景
                            },
                            Dependency = DependenciesStrategy.Direct,
                            PackStrategy = PackStrategy.Default,
                        },

            new PackTargetConfig
                        {
                            Type = BundleType.Scene,
                            Name = "Scene",
                            AssetPath = new[]
                            {
                                "Scenes/wangquanbieyuan.unity",
                                "Scenes/renleichengchi.unity",
                                "Scenes/DailyDungeon.unity",
                                "Scenes/dailyProto.unity",

                                "Scenes/AssetBundleTest", //TEST
                                "Scenes/BattleMaps",
                                "Scenes/Login.unity",
                                "Scenes/Lobby.unity",
                                "Scenes/Story.unity",
                            },
                            Dependency = DependenciesStrategy.All,
                            PackStrategy = PackStrategy.Default,
                        },
        };

        /// <summary>
        /// 默认过滤设置(不进行打包的类型)
        /// 控制器动画资源和模型打包在一起
        /// </summary>
        private static readonly string[] ConstDefaultIgnoreTypePostfix = new string[]
        {
            ".meta",
            "unity default resources",
            "unity_builtin_extra",
            "dll",
            ".cs",
            ".js",

            //"fbx",                  
            // ".controller",         
            //".overridecontroller",
            ".anim",

            //".shader",
            //".mat",
            //".png",
            //".psd",
            //".tga",
            //".jpg",
        };

        private static readonly IgnoreTypeConfig[] mIgnoreTypeConfigs = new IgnoreTypeConfig[]
        {
            new IgnoreTypeConfig
            {
                BundleType = BundleType.Max,
                ConfigName = "Default",
                NamePostfixs = ConstDefaultIgnoreTypePostfix,
            },

            // texture pack with mat
            new IgnoreTypeConfig
            {
                BundleType = BundleType.Character,   //材质和贴图放在一起，动画文件和Anim打包在一起，FBX单独打包
                ConfigName = "Character",
                NamePostfixs =
                    ConstDefaultIgnoreTypePostfix.Concat(new string[] {".png", ".psd", ".jpg", ".tga"}).ToArray(),
            },

            new IgnoreTypeConfig
            {
                BundleType = BundleType.Scene,      //材质和贴图放在一起，动画文件和Anim打包在一起，FBX单独打包
                ConfigName = "Scene",
                NamePostfixs =
                    ConstDefaultIgnoreTypePostfix.Concat(new string[] {".png", ".psd", ".jpg", ".tga"}).ToArray(),
            },
        };

        public static List<string> GetIgnoreTypePostfix(BundleType type)
        {
            for (int i = 0; i < mIgnoreTypeConfigs.Length; ++i)
            {
                if (mIgnoreTypeConfigs[i].BundleType == type)
                {
                    return mIgnoreTypeConfigs[i].NamePostfixs.ToList();
                }
            }
            return mIgnoreTypeConfigs[0].NamePostfixs.ToList();
        }

        public static int PackTargetCount
        {
            get { return mPackTargetConfigs.Length; }
        }

        public static string GetManitestName()
        {
            return AssetBundlesPath;
        }

        public static string GetAssetBundleName(string assetPath)
        {
            if (string.IsNullOrEmpty(assetPath))
            {
                return string.Empty;
            }

            PackTargetConfig targetConfig = GetPackTargetConfig(assetPath);
            if (targetConfig == null)
            {
                return string.Empty;
            }

            if (targetConfig.PackStrategy == PackStrategy.One)
            {
                assetPath = AssetBundleUtil.Normarlize(assetPath);
                string inputBundleName = assetPath.Substring(0, assetPath.LastIndexOf("/"));

                return AssetBundleUtil.GetBundleName(inputBundleName);
            }
            else if (targetConfig.PackStrategy == PackStrategy.Default)
            {
                return AssetBundleUtil.GetBundleName(assetPath);
            }

            return string.Empty;
        }

        private static PackTargetConfig GetPackTargetConfig(string assetPath)
        {
            if (string.IsNullOrEmpty(assetPath))
            {
                return null;
            }

            //TODO 文件夹嵌套文件件的情况
            assetPath = AssetBundleUtil.Normarlize(assetPath);
            string inputBundleName = assetPath.Substring(0, assetPath.LastIndexOf("/"));

            for (int i = 0; i < PackTargetCount; ++i)
            {
                PackTargetConfig targetConfig = mPackTargetConfigs[i];

                for (int j = 0; j < targetConfig.AssetPath.Length; ++j)
                {
                    if (targetConfig.AssetPath[j] == inputBundleName)
                    {
                        return targetConfig;
                    }
                }
            }

            return null;
        }

        public static PackTargetConfig[] GetPackTargetConfig(BundleType type)
        {
            if (type == BundleType.Max)
            {
                return mPackTargetConfigs;
            }

            for (int i = 0; i < PackTargetCount; ++i)
            {
                PackTargetConfig targetConfig = mPackTargetConfigs[i];
                if (targetConfig.Type == type)
                {
                    return new[] {targetConfig};
                }
            }
            return null;
        }

        public static string[] GetPackTargetAssetPath(BundleType type)
        {
            if (type == BundleType.Max)
            {
                return GetPackTargetAssetPath();
            }

            PackTargetConfig[] targetConfigs = GetPackTargetConfig(type);
            if (targetConfigs != null)
            {
                string[] res = new string[targetConfigs[0].AssetPath.Length];
                for (int k = 0; k < res.Length; k++)
                {
                    res[k] = Application.dataPath + "/" + targetConfigs[0].AssetPath[k];
                }
                return res;
            }

            return null;
        }

        public static string[] GetPackTargetAssetPath()
        {
            List<string> allResourcesPaths = new List<string>();
            for (int i = 0; i < PackTargetCount; i++)
            {
                PackTargetConfig targetConfig = mPackTargetConfigs[i];
                allResourcesPaths.AddRange(GetPackTargetAssetPath(targetConfig.Type));
            }

            return allResourcesPaths.ToArray();
        }

        public static string[] GetPackTargetPathUnderResourcesPath()
        {
            string prefix = Application.dataPath + "/Resources/";
            List<string> allResourcesPaths = GetPackTargetAssetPath().ToList();

            for (int i = allResourcesPaths.Count - 1; i >= 0; i--)
            {
                if (!allResourcesPaths[i].StartsWith(prefix))
                {
                    allResourcesPaths.RemoveAt(i);
                }
                else
                {
                    allResourcesPaths[i] = allResourcesPaths[i].Substring(prefix.Length);
                }
            }
            return allResourcesPaths.ToArray();
        }

        public static string GetAssetBundlePath(string relativePath)
        {
            return Core.Platform.Instance.GetPath(AssetBundlesPath + "/" + relativePath);
        }

        public static string GetAssetBundleBundleUrl(string relativePath)
        {
            return Core.Platform.Instance.GetBundleURL(AssetBundlesPath + "/" + relativePath);
        }

        //    private static string GetAssetBundlePrefix(bool isSync)
        //    {
        //        // 异步地址
        //        if (!isSync)
        //        {
        //            string PathURL =
        //#if UNITY_ANDROID && !UNITY_EDITOR
        //                    "jar:file://" + Application.dataPath + "!/assets/";
        //#elif UNITY_IPHONE  //iPhone  
        //                    Application.dataPath + "/Raw/";  
        //#elif UNITY_STANDALONE_WIN || UNITY_EDITOR
        //                "file://" + Application.dataPath + "/StreamingAssets/";
        //#else
        //                    string.Empty;  
        //#endif
        //            return PathURL;
        //        }

        //        // 同步地址
        //#if NON_IFS_REALEASE
        //        return Application.persistentDataPath;
        //#elif UNITY_ANDROID && !UNITY_EDITOR
        //        return Application.dataPath + "!assets/";
        //#else
        //    #if UNITY_EDITOR
        //            return Application.streamingAssetsPath + "/";
        //    #else
        //            return Application.persistentDataPath + "/";     
        //    #endif
        //#endif
        //    }

        //todo 测试使用
        //public static string GetAssetBundleOutputPath()
        //{
        //    return Application.dataPath + "/StreamingAssets/" + AssetBundlesPath + "/";
        //}

        //    //TODO
        //    private static string GetAssetBundlePrefix(bool isSync)
        //    {
        //        // 异步地址
        //        if (!isSync)
        //        {
        //#if NON_IFS_REALEASE
        //            return "file:///" + Application.persistentDataPath;
        //#else
        //            return
        //#if UNITY_EDITOR || !UNITY_ANDROID
        //                "file://" +
        //#endif
        //                Application.streamingAssetsPath;
        //#endif
        //        }
        //            // 同步地址
        ////#if NON_IFS_REALEASE
        //            return Application.persistentDataPath;
        ////#elif UNITY_ANDROID && !UNITY_EDITOR
        ////            return Application.dataPath + "!assets";
        ////#else
        ////        return Application.streamingAssetsPath;
        ////#endif
        //    }


        //    //TODO
        //    public static string GetAssetBundleBasePath(bool isSync = false)
        //    {
        //        string path = GetAssetBundlePrefix(isSync) + "/data/" + AssetBundlesPath + "/";
        //        return path;
        //    }


        //    //TODO
        //    public static string GetAssetsOutputath()
        //    {
        //        string path = Application.dataPath;
        //        path = path.Substring(0, path.Length - "Assets".Length);
        //        path += AssetBundlesPath + "/";

        //        //path = Application.streamingAssetsPath + "/" + AssetBundlesPath + "/";

        //        return path;
        //    }
    }
}