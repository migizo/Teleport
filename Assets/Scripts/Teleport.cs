using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Teleport : MonoBehaviour
{
  [SerializeField] GameObject modelObj;
  [SerializeField] GameObject appearParticle;
  [SerializeField] GameObject disappearParticle;
  [SerializeField] float modelActiveTime;
  [SerializeField] float particleDeactiveTime;
  public float totalTime { get { return particleDeactiveTime; } }

  public void Disappear()
  {
    StartCoroutine(DisappearLoutine());
  }

  public void Appear(Vector3 pos)
  {
    StartCoroutine(AppearLoutine(pos));
  }

  IEnumerator DisappearLoutine()
  {
    disappearParticle.transform.position = modelObj.transform.position;
    disappearParticle.SetActive(true);
    var particleSystem = disappearParticle.GetComponent<ParticleSystem>();
    particleSystem.Play();
    yield return new WaitForSeconds(modelActiveTime);
    modelObj.SetActive(false);
    yield return new WaitForSeconds(particleDeactiveTime - modelActiveTime);
    particleSystem.Stop();
    disappearParticle.SetActive(false);

  }

  IEnumerator AppearLoutine(Vector3 pos)
  {
    appearParticle.SetActive(true);
    modelObj.transform.position = pos;
    appearParticle.transform.position = modelObj.transform.position;
    var particleSystem = appearParticle.GetComponent<ParticleSystem>();
    particleSystem.Play();
    yield return new WaitForSeconds(modelActiveTime);
    modelObj.SetActive(true);
    yield return new WaitForSeconds(particleDeactiveTime - modelActiveTime);
    particleSystem.Stop();
    appearParticle.SetActive(false);
  }
}
