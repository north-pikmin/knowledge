WSL and Selenium for python
===========================

.. |cover_picture| image:: /src/python/images/cover.png
   :width: 430px

|cover_picture|

In order to have everything working correctly, two softwares must be installed:

- Mozilla Firefox

- A Web driver (`Geckodriver` here)

.. note::

   The web browser Mozilla Firefox uses an engine named the Gecko browser engine. The engine was created by the Mozilla foundation.


Install Firefox via APT (not snap)
----------------------------------

**Step 1** Remove the Firefox Snap by running the following command in a new Terminal window

.. code::

   sudo snap remove firefox


**Step 2** Add the (Ubuntu) Mozilla team PPA to your list of software sources by running the following command in the same Terminal window

.. code::

   sudo add-apt-repository ppa:mozillateam/ppa

**Step 3** Next, alter the Firefox package priority to ensure the PPA/deb/apt version of Firefox is preferred.

.. code::

   echo '
   Package: *
   Pin: release o=LP-PPA-mozillateam
   Pin-Priority: 1001
   ' | sudo tee /etc/apt/preferences.d/mozilla-firefox

**Step 4** Copy this for future Firefox upgrades to be installed automatically.

.. code::

   echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

**Step 5** Finally install firefox

.. code::

   sudo apt install firefox

Now that firefox is installed, you can try to lauch the webbrowser by calling it:

.. code::

   firefox

Install GeckoDriver
-------------------

.. |gecko_last_release| image:: /src/python/images/gecko.png
   :width: 500px

**Step 1** Download ``geckodriver``

You can find the latest version on `github <https://github.com/mozilla/geckodriver/releases/latest>`. Select ``*-linux64.tar.gz`` file.

|gecko_last_release|


**Step 2** Install the driver

.. |gecko_extract| image:: /src/python/images/extract.png
   :width: 500px

.. |gecko_copy| image:: /src/python/images/copy.png
   :width: 500px


.. tab:: Extract `geckodriver`

   |gecko_extract|


.. tab:: Move file to /usr/bin

   |gecko_copy|

.. tab:: Check installation

   .. code::

      find /usr/bin/geckodriver

   If no error is raised, then the installation is complete !

.. tab:: Check .bashrc

   On `.bashrc` file, add :

   .. code::

      export DISPLAY=$(ip route | awk '{print $3; exit}'):0


Test Selenium
-------------

The code bellow opens an amazon.fr page for ~10 seconds

.. code::

   import time
   from selenium import webdriver


   if __name__ == "__main__":
      browser = webdriver.Firefox()

      browser.get("https://www.amazon.fr/")

      time.sleep(15)

      browser.close()
