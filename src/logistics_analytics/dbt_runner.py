import docker
import logging

logger = logging.getLogger(__name__)


def run_dbt_command(command: str, dbt_container_name: str = "dbt") -> str:
    """
    Exec a dbt command inside the running dbt container.

    Args:
        command: dbt command to run, e.g. "dbt run" or "dbt test"
        dbt_container_name: the name/id of the dbt container in docker-compose
                            
    Returns:
        stdout output as string
    Raises:
        Exception if the command exits with a non-zero code
    """
    client = docker.from_env()

    # Find the container — match by name substring to handle compose prefixes
    containers = client.containers.list(filters={"status": "running"})
    dbt_container = next(
        (c for c in containers if dbt_container_name in c.name),
        None
    )

    if not dbt_container:
        raise Exception(
            f"No running container found matching name '{dbt_container_name}'. "
            f"Running containers: {[c.name for c in containers]}"
        )

    logger.info(f"Executing '{command}' in container '{dbt_container.name}'")

    exec_result = dbt_container.exec_run(
        cmd=command,
        workdir="/usr/app/dbt/logistics_analytics",   # matches your compose working_dir
        stream=True,
        demux=False,
    )

    output_lines = []
    for chunk in exec_result.output:
        line = chunk.decode("utf-8", errors="replace").rstrip()
        logger.info(f"[dbt] {line}")
        output_lines.append(line)

    full_output = "\n".join(output_lines)

    # exec_run with stream=True doesn't give exit code directly,
    # so re-run without stream just to get the exit code
    exit_result = dbt_container.exec_run(cmd=command, workdir="/usr/app/dbt/logistics_analytics")
    if exit_result.exit_code != 0:
        raise Exception(
            f"dbt command '{command}' failed with exit code {exit_result.exit_code}.\n"
            f"Output:\n{exit_result.output.decode('utf-8', errors='replace')}"
        )

    return full_output