import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
import time

START_URL = "https://example.com"
MAX_PAGES = 50
DELAY = 1  # seconds between requests

visited = set()
to_visit = [START_URL]

def is_same_domain(url, base):
    return urlparse(url).netloc == urlparse(base).netloc

while to_visit and len(visited) < MAX_PAGES:
    url = to_visit.pop(0)

    if url in visited:
        continue

    try:
        print(f"Crawling: {url}")
        response = requests.get(url, timeout=10, headers={
            "User-Agent": "Mozilla/5.0 (compatible; SimpleCrawler/1.0)"
        })
        response.raise_for_status()

        soup = BeautifulSoup(response.text, "html.parser")
        visited.add(url)

        # ---- Extract page text ----
        page_text = soup.get_text(separator=" ", strip=True)
        print(f"Text length: {len(page_text)}")

        # ---- Extract links ----
        for link in soup.find_all("a", href=True):
            absolute_url = urljoin(url, link["href"])
            absolute_url = absolute_url.split("#")[0]  # remove fragments

            if (
                is_same_domain(absolute_url, START_URL)
                and absolute_url not in visited
                and absolute_url not in to_visit
            ):
                to_visit.append(absolute_url)

        time.sleep(DELAY)

    except Exception as e:
        print(f"Failed: {url} ({e})")

print("Crawling finished")
