from src.nebari_cert_manager.plugin import CertManagerStage, CertManagerConfig, InputSchema

class TestConfig(InputSchema):
    namespace: str
    domain: str

def test_ctor():
    sut = CertManagerStage(output_directory = None, config = None)
    assert sut.name == "cert-manager"
    assert sut.priority == 100

def test_input_vars():
    config = TestConfig(namespace = "nebari-ns", domain = "my-test-domain.com")
    sut = CertManagerStage(output_directory = None, config = config)

    stage_outputs = get_stage_outputs()
    result = sut.input_vars(stage_outputs)
    assert result["domain"] == "my-test-domain.com"

def test_default_namespace():
    config = TestConfig(namespace = "nebari-ns", domain = "my-test-domain.com")
    sut = CertManagerStage(output_directory = None, config = config)

    stage_outputs = get_stage_outputs()
    result = sut.input_vars(stage_outputs)
    assert result["create_namespace"] == False
    assert result["namespace"] == "nebari-ns"

def test_chart_namespace():
    config = TestConfig(namespace = "nebari-ns", domain = "my-test-domain.com", cert_manager = CertManagerConfig(namespace = "cert-manager-ns"))
    sut = CertManagerStage(output_directory = None, config = config)

    stage_outputs = get_stage_outputs()
    result = sut.input_vars(stage_outputs)
    assert result["create_namespace"] == True
    assert result["namespace"] == "cert-manager-ns"

def test_chart_overrides():
    config = TestConfig(namespace = "nebari-ns", domain = "my-test-domain.com", cert_manager = CertManagerConfig(values = { "foo": "bar" }))
    sut = CertManagerStage(output_directory = None, config = config)

    stage_outputs = get_stage_outputs()
    result = sut.input_vars(stage_outputs)
    assert result["overrides"] == { "foo": "bar" }

def get_stage_outputs():
    return {
        "stages/04-kubernetes-ingress": {
            "domain": "my-test-domain.com"
        }
    }