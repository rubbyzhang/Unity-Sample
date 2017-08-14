using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneMgr : MonoBehaviour {

    public static Scene GetActiveScene()
    {
        return SceneManager.GetActiveScene();
    }


    public static void LoadSceneFromAssetBundle(string sceneName, LoadSceneMode mode = LoadSceneMode.Single)
    {
        ResourceService.Instance.LoadSceneByName(sceneName, mode );
    }

    public static LoadAsyncOperation LoadSceneAsyncFromAssetBundle(string sceneName, LoadSceneMode mode = LoadSceneMode.Single)
    {
        return ResourceService.Instance.LoadSceneByNameAsync(sceneName, mode);
    }

    public static void LoadScene(int sceneBuildIndex, LoadSceneMode mode = LoadSceneMode.Single) {
        SceneManager.LoadScene(sceneBuildIndex, mode);
    }

    public static void LoadScene(string sceneName, LoadSceneMode mode = LoadSceneMode.Single) {
        SceneManager.LoadScene(sceneName, mode);
        //GlobalShaderUniformInitializer.ResetGlobalShaderUniforms();
    }

    public static AsyncOperation LoadSceneAsync(int sceneBuildIndex, LoadSceneMode mode = LoadSceneMode.Single) {
        return SceneManager.LoadSceneAsync(sceneBuildIndex, mode);
    }

    public static AsyncOperation LoadSceneAsync(string sceneName, LoadSceneMode mode = LoadSceneMode.Single) {
        return SceneManager.LoadSceneAsync(sceneName, mode);
    }

    public static bool UnloadScene(Scene scene) {
        return SceneManager.UnloadScene(scene);
    }

    public static bool UnloadScene(string sceneName) {
        return SceneManager.UnloadScene(sceneName);
    }

    public static bool UnloadScene(int sceneBuildIndex) {
        return SceneManager.UnloadScene(sceneBuildIndex);
    }

    public static AsyncOperation UnloadSceneAsync(Scene scene) {
        return SceneManager.UnloadSceneAsync(scene);
    }

    public static AsyncOperation UnloadSceneAsync(string sceneName) {
        return SceneManager.UnloadSceneAsync(sceneName);
    }

    public static bool SetActiveScene(Scene scene) {
        bool value = SceneManager.SetActiveScene(scene);
        //GlobalShaderUniformInitializer.ResetGlobalShaderUniforms();
        return value;
    }

    public static Scene GetSceneByName(string name) {
        return SceneManager.GetSceneByName(name);
    }
}
