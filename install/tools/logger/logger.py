import logging
from colorlog import ColoredFormatter

def get_logger(name="pythonConfig", level=logging.DEBUG):
    fmt = "  %(log_color)s%(levelname)-8s%(reset)s | %(log_color)s%(message)s%(reset)s"

    logger = logging.getLogger(name)

    # avoid adding handlers multiple times (common in notebooks / re-imports)
    if getattr(logger, "_mylogger_configured", False):
        return logger

    logger.setLevel(level)

    handler = logging.StreamHandler()
    handler.setLevel(level)
    handler.setFormatter(ColoredFormatter(fmt))

    logger.addHandler(handler)
    logger.propagate = False
    logger._mylogger_configured = True
    return logger
