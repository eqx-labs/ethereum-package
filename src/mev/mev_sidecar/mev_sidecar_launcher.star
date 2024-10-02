redis_module = import_module("github.com/kurtosis-tech/redis-package/main.star")
postgres_module = import_module("github.com/kurtosis-tech/postgres-package/main.star")
constants = import_module("../../package_io/constants.star")
mev_boost_context_util = import_module("../mev_boost/mev_boost_context.star")

MEV_SIDECAR_ENDPOINT = "http://mev-sidecar-api"

MEV_SIDECAR_ENDPOINT_PORT = 9061
MEV_SIDECAR_BOOST_PROXY_PORT = 9062
MEV_SIDECAR_METRICS_PORT = 9063

# The min/max CPU/memory that mev-sidecar can use
MEV_SIDECAR_MIN_CPU = 100
MEV_SIDECAR_MAX_CPU = 1000
MEV_SIDECAR_MIN_MEMORY = 128
MEV_SIDECAR_MAX_MEMORY = 1024

def launch_mev_sidecar(
    plan,
    image,
    sidecar_config,
    network_params,
    node_selectors,
):
    env_vars = {
        "RUST_LOG": "bolt_sidecar=trace",
    }

    api = plan.add_service(
        name="mev-sidecar-api",
        config=ServiceConfig(
            image=image,
            cmd=[
                "--port",
                str(MEV_SIDECAR_ENDPOINT_PORT),
                "--private-key",
                # Random private key for testing, generated with `openssl rand -hex 32`
                "18d1c5302e734fd6fbfaa51828d42c4c6d3cbe020c42bab7dd15a2799cf00b82",
                "--constraints-url",
                sidecar_config["constraints_api_url"],
                "--constraints-proxy-port",
                str(MEV_SIDECAR_BOOST_PROXY_PORT),
                "--beacon-api-url",
                sidecar_config["beacon_api_url"],
                "--execution-api-url",
                sidecar_config["execution_api_url"],
                "--engine-api-url",
                sidecar_config["engine_api_url"],
                "--fee-recipient",
                "0x0000000000000000000000000000000000000000",
                "--jwt-hex",
                sidecar_config["jwt_hex"],
                "--commitment-deadline",
                str(100),
                "--chain",
                "kurtosis",
                "--validator-indexes",
                "0..64",
                "--slot-time",
                str(network_params.seconds_per_slot),
                "--metrics-port",
                str(MEV_SIDECAR_METRICS_PORT),
            ],
            # + mev_params.mev_relay_api_extra_args,
            ports={
                "api": PortSpec(
                    number=MEV_SIDECAR_ENDPOINT_PORT, transport_protocol="TCP"
                ),
                "mevboost-proxy": PortSpec(
                    number=MEV_SIDECAR_BOOST_PROXY_PORT, transport_protocol="TCP"
                ),
                "metrics": PortSpec(
                    number=MEV_SIDECAR_METRICS_PORT, transport_protocol="TCP"
                ),
            },
            env_vars=env_vars,
            min_cpu=MEV_SIDECAR_MIN_CPU,
            max_cpu=MEV_SIDECAR_MAX_CPU,
            min_memory=MEV_SIDECAR_MIN_MEMORY,
            max_memory=MEV_SIDECAR_MAX_MEMORY,
            node_selectors=node_selectors,
        ),
    )

    return struct(
        ip_addr=api.ip_address,
        metrics_port_num=MEV_SIDECAR_METRICS_PORT,
    )
